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

        # -----------------------------
        # Parse body
        # -----------------------------
        body = event.get("body")

        if not body:
            return response(400, {"message": "Request body is required"})

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")
        otp = body.get("otp")

        if not email or not otp:
            return response(400, {"message": "Email and OTP are required"})

        email = email.strip().lower()
        otp = str(otp).strip()

        print("Verifying email:", email)
        print("Entered OTP:", otp)

        # -----------------------------
        # Get OTP from DB
        # -----------------------------
        res = otp_table.get_item(Key={"email": email})

        if "Item" not in res:
            return response(400, {"message": "OTP not found"})

        item = res["Item"]

        print("Stored OTP:", item.get("otp"))

        # -----------------------------
        # Validate OTP
        # -----------------------------
        if item.get("used", False):
            return response(400, {"message": "OTP already used"})

        if int(time.time()) > item.get("expiry", 0):
            return response(400, {"message": "OTP expired"})

        if item.get("otp") != otp:
            return response(400, {"message": "Invalid OTP"})

        # -----------------------------
        # Mark OTP as used
        # -----------------------------
        otp_table.update_item(
            Key={"email": email},
            UpdateExpression="SET #u = :val",
            ExpressionAttributeNames={"#u": "used"},
            ExpressionAttributeValues={":val": True}
        )

        print("OTP marked as used")

        # -----------------------------
        # Generate JWT
        # -----------------------------
        token = jwt.encode(
            {
                "email": email,
                "exp": int(time.time()) + 3600  # 1 hour
            },
            SECRET,
            algorithm="HS256"
        )

        print("JWT generated")

        return response(200, {
            "message": "OTP verified successfully",
            "token": token
        })

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {"message": "Internal server error"})


# -----------------------------
# RESPONSE HELPER
# -----------------------------
def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
