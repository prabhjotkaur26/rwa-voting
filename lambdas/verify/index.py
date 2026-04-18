import json
import boto3
import os
import time
import jwt

# -----------------------------
# AWS SETUP
# -----------------------------
dynamodb = boto3.resource('dynamodb')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
JWT_SECRET = os.environ['JWT_SECRET']


# -----------------------------
# RESPONSE HELPER
# -----------------------------
def response(status, body, headers=None):
    return {
        "statusCode": status,
        "headers": headers or {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # PARSE BODY
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")
        otp = body.get("otp")

        if not email or not otp:
            return response(400, {"message": "Email and OTP required"})

        email = email.strip().lower()

        # -----------------------------
        # FETCH OTP
        # -----------------------------
        res = otp_table.get_item(Key={"email": email})

        if "Item" not in res:
            return response(400, {"message": "Invalid OTP"})

        item = res["Item"]

        # -----------------------------
        # CHECK EXPIRY
        # -----------------------------
        if int(time.time()) > item.get("expiry", 0):
            return response(400, {"message": "OTP expired"})

        # -----------------------------
        # CHECK OTP VALIDITY
        # -----------------------------
        if item.get("otp") != otp or item.get("used"):
            return response(400, {"message": "Invalid OTP"})

        # -----------------------------
        # MARK OTP AS USED
        # -----------------------------
        otp_table.update_item(
            Key={"email": email},
            UpdateExpression="SET used = :u",
            ExpressionAttributeValues={":u": True}
        )

        # -----------------------------
        # ROLE SYSTEM (IMPORTANT FIX)
        # -----------------------------
        is_admin = os.environ.get("ADMIN_EMAIL") == email

        role = "admin" if is_admin else "voter"

        # -----------------------------
        # GENERATE JWT
        # -----------------------------
        token = jwt.encode(
            {
                "email": email,
                "role": role,
                "exp": int(time.time()) + 3600
            },
            JWT_SECRET,
            algorithm="HS256"
        )

        # -----------------------------
        # SUCCESS RESPONSE
        # -----------------------------
        return response(200, {
            "token": token,
            "role": role
        })

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {
            "message": "Internal server error"
        })
