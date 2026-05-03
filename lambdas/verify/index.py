import json
import boto3
import jwt
import time
import os

dynamodb = boto3.resource("dynamodb", region_name="ap-south-1")
otp_table = dynamodb.Table(os.environ["OTP_TABLE"])

SECRET = os.environ["JWT_SECRET"]


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        email = body.get("email")
        otp = body.get("otp")

        if not email or not otp:
            return response(400, "Email & OTP required")

        email = email.strip().lower()

        res = otp_table.get_item(Key={"email": email})
        if "Item" not in res:
            return response(400, "OTP not found")

        item = res["Item"]

        if item["used"]:
            return response(400, "OTP used")

        if int(time.time()) > item["expiry"]:
            return response(400, "OTP expired")

        if item["otp"] != otp:
            return response(400, "Invalid OTP")

        # mark used
        otp_table.update_item(
            Key={"email": email},
            UpdateExpression="SET used = :u",
            ExpressionAttributeValues={":u": True}
        )

        token = jwt.encode(
            {"email": email, "exp": int(time.time()) + 3600},
            SECRET,
            algorithm="HS256"
        )

        return response(200, {"token": token})

    except Exception as e:
        print(e)
        return response(500, "Server error")


def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body if isinstance(body, dict) else {"message": body})
    }
