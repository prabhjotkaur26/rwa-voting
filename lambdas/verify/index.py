import json
import boto3
import os
import time
import jwt

dynamodb = boto3.resource('dynamodb')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
JWT_SECRET = os.environ['JWT_SECRET']


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")
        otp = body.get("otp")

        if not email or not otp:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Email and OTP required"})
            }

        # -----------------------------
        # FETCH OTP
        # -----------------------------
        res = otp_table.get_item(Key={"email": email})

        if "Item" not in res:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Invalid OTP"})
            }

        item = res["Item"]

        # -----------------------------
        # CHECK EXPIRY
        # -----------------------------
        if int(time.time()) > item["expiry"]:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "OTP expired"})
            }

        # -----------------------------
        # CHECK OTP MATCH + USED
        # -----------------------------
        if item["otp"] != otp or item.get("used"):
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Invalid OTP"})
            }

        # -----------------------------
        # MARK OTP AS USED
        # -----------------------------
        otp_table.update_item(
            Key={"email": email},
            UpdateExpression="SET used = :u",
            ExpressionAttributeValues={":u": True}
        )

        # -----------------------------
        # ADMIN LOGIC
        # -----------------------------
        is_admin = True if email == "admin@gmail.com" else False

        # -----------------------------
        # GENERATE JWT
        # -----------------------------
        token = jwt.encode(
            {
                "email": email,
                "isAdmin": is_admin,
                "exp": int(time.time()) + 3600
            },
            JWT_SECRET,
            algorithm="HS256"
        )

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "token": token,
                "isAdmin": is_admin
            })
        }

    except Exception as e:
        print("ERROR:", str(e))

        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error",
                "error": str(e)
            })
        }
