import json
import boto3
import random
import time
import os

# -----------------------------
# AWS CLIENTS
# -----------------------------
dynamodb = boto3.resource("dynamodb", region_name="ap-south-1")
ses = boto3.client("ses", region_name="ap-south-1")

otp_table = dynamodb.Table(os.environ["OTP_TABLE"])
voter_table = dynamodb.Table(os.environ["VOTER_TABLE"])

SENDER = os.environ.get("SENDER_EMAIL")


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # Parse request body
        # -----------------------------
        body = event.get("body")

        if not body:
            return response(400, "Request body is required")

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")

        if not email:
            return response(400, "Email is required")

        email = email.strip().lower()
        print("Requested email:", email)

        # -----------------------------
        # Check voter exists
        # -----------------------------
        res = voter_table.get_item(Key={"email": email})

        if "Item" not in res:
            print("Email not found in voter table")
            return response(403, "Not a registered voter")

        # -----------------------------
        # Validate sender email
        # -----------------------------
        if not SENDER:
            print("ERROR: SENDER_EMAIL not set")
            return response(500, "Server email sender not configured")

        print("Sender email:", SENDER)

        # -----------------------------
        # Generate OTP
        # -----------------------------
        otp = str(random.randint(100000, 999999))
        expiry = int(time.time()) + 300  # 5 minutes

        print("Generated OTP:", otp)

        # -----------------------------
        # Store OTP in DynamoDB
        # -----------------------------
        otp_table.put_item(
            Item={
                "email": email,
                "otp": otp,
                "expiry": expiry,
                "used": False
            }
        )

        print("OTP stored in DB")

        # -----------------------------
        # Send OTP via SES
        # -----------------------------
        try:
            response_ses = ses.send_email(
                Source=SENDER,
                Destination={
                    "ToAddresses": [email]
                },
                Message={
                    "Subject": {
                        "Data": "RWA Voting OTP Verification"
                    },
                    "Body": {
                        "Text": {
                            "Data": f"Your OTP is {otp}. Valid for 5 minutes."
                        }
                    }
                }
            )

            print("SES Response:", response_ses)

        except Exception as e:
            print("SES ERROR:", str(e))
            return response(
                500,
                "Failed to send OTP",
                "Check if email is verified in SES (sandbox mode)"
            )

        return response(200, "OTP sent successfully")

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, "Internal server error", str(e))


# -----------------------------
# RESPONSE HELPER
# -----------------------------
def response(status, message, error=None):
    body = {
        "message": message
    }
    if error:
        body["error"] = error

    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
