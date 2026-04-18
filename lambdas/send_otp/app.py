import json
import boto3
import random
import time
import os
import re

# -----------------------------
# AWS CLIENTS
# -----------------------------
dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')

table = dynamodb.Table(os.environ['OTP_TABLE'])
SENDER = os.environ['SENDER_EMAIL']


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


# -----------------------------
# EMAIL VALIDATION
# -----------------------------
def is_valid_email(email):
    pattern = r"^[\w\.-]+@[\w\.-]+\.\w+$"
    return re.match(pattern, email)


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # PARSE BODY SAFELY
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")

        if not email:
            return response(400, {"message": "Email is required"})

        email = email.strip().lower()

        # -----------------------------
        # VALIDATE EMAIL
        # -----------------------------
        if not is_valid_email(email):
            return response(400, {"message": "Invalid email format"})

        # -----------------------------
        # GENERATE OTP
        # -----------------------------
        otp = str(random.randint(100000, 999999))
        expiry = int(time.time()) + 300  # 5 minutes

        # -----------------------------
        # STORE OTP (WITH TTL)
        # -----------------------------
        table.put_item(
            Item={
                "email": email,
                "otp": otp,
                "expiry": expiry,
                "used": False,
                "ttl": expiry  # IMPORTANT for DynamoDB auto delete
            }
        )

        # -----------------------------
        # SEND EMAIL
        # -----------------------------
        ses.send_email(
            Source=SENDER,
            Destination={
                "ToAddresses": [email]
            },
            Message={
                "Subject": {
                    "Data": "Your OTP for RWA Voting System"
                },
                "Body": {
                    "Text": {
                        "Data": f"Your OTP is {otp}. It is valid for 5 minutes. Do not share it."
                    }
                }
            }
        )

        return response(200, {
            "message": "OTP sent successfully"
        })

    except Exception as e:
        print("ERROR:", str(e))

        return response(500, {
            "message": "Internal server error"
        })
