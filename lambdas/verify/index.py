import json
import boto3
import jwt
import time
import os

# AWS CLIENT
dynamodb = boto3.resource("dynamodb", region_name="ap-south-1")
otp_table = dynamodb.Table(os.environ["OTP_TABLE"])

SECRET = os.environ["JWT_SECRET"]

def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # Parse body
        body = event.get("body")

        if not body:
            return response(400, "Request body is required")

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")
        otp = body.get("otp")

        if not email or not otp:
            return response(400, "Email and OTP are required")

        email = email.strip().lower()

        # Get OTP
        res = otp_table.get_item(Key={"email": email})

        if "Item" not in res:
            return response(400, "OTP not found")

        item = res["Item"]

        if item["otp"] != otp:
            return response(400, "Invalid OTP")

        if item.get("used", False):
            return response(400, "OTP already used")

        if int(time.time()) > item["expiry"]:
            return response(400, "OTP expired")

        # Mark OTP as used
        otp_table.update_item(
            Key={"email": email},
            UpdateExpression="SET #u = :val",
            ExpressionAttributeNames={"#u": "used"},
            ExpressionAttributeValues={":val": True}
        )

        # Generate JWT
        token = jwt.encode(
            {"email": email, "exp": int(time.time()) + 3600},
            SECRET,
            algorithm="HS256"
        )

        return response(200, {"message": "OTP verified", "token": token})

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, "Internal server error")


def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }