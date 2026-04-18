import json
import boto3
import random
import time
import os

# -----------------------------
# AWS CLIENTS
# -----------------------------
dynamodb = boto3.resource("dynamodb")
ses = boto3.client("ses")

otp_table = dynamodb.Table(os.environ["OTP_TABLE"])
voter_table = dynamodb.Table(os.environ["VOTER_TABLE"])

SENDER = os.environ["SENDER_EMAIL"]


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # Parse API Gateway body
        # -----------------------------
        body = event.get("body")

        if body is None:
            return response(400, "Request body is required")

        if isinstance(body, str):
            try:
                body = json.loads(body)
            except json.JSONDecodeError:
                return response(400, "Invalid JSON body")

        if not isinstance(body, dict):
            return response(400, "Invalid request format")

        email = body.get("email")

        if not email:
            return response(400, "Email is required")

        email = email.strip().lower()

        # -----------------------------
        # Check voter exists
        # -----------------------------
        res = voter_table.get_item(Key={"email": email})

        if "Item" not in res:
            return response(403, "Not a registered voter")

        # -----------------------------
        # Generate OTP
        # -----------------------------
        otp = str(random.randint(100000, 999999))
        expiry = int(time.time()) + 300  # 5 minutes

        # -----------------------------
        # Store OTP (overwrite old)
        # -----------------------------
        otp_table.put_item(
            Item={
                "email": email,
                "otp": otp,
                "expiry": expiry,
                "used": False,
                "ttl": expiry  # DynamoDB auto expiry
            }
        )

        # -----------------------------
        # Send OTP via SES
        # -----------------------------
        ses.send_email(
            Source=SENDER,
            Destination={"ToAddresses": [email]},
            Message={
                "Subject": {
                    "Data": "Your OTP for Voting System"
                },
                "Body": {
                    "Text": {
                        "Data": f"Your OTP is {otp}. It is valid for 5 minutes. Do not share it with anyone."
                    }
                }
            }
        )

        # -----------------------------
        # Success response
        # -----------------------------
        return response(200, "OTP sent successfully")

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, "Internal server error")


# -----------------------------
# HELPER RESPONSE FUNCTION
# -----------------------------
def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": message
        })
    }
