import json
import boto3
import random
import time
import os

dynamodb = boto3.resource("dynamodb", region_name="ap-south-1")
ses = boto3.client("ses", region_name="ap-south-1")

otp_table = dynamodb.Table(os.environ["OTP_TABLE"])
voter_table = dynamodb.Table(os.environ["VOTER_TABLE"])

SENDER = os.environ.get("SENDER_EMAIL")


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        body = json.loads(event.get("body", "{}"))
        email = body.get("email")

        if not email:
            return response(400, "Email is required")

        email = email.strip().lower()

        # Check voter
        res = voter_table.get_item(Key={"email": email})
        if "Item" not in res:
            return response(403, "Not registered voter")

        if not SENDER:
            return response(500, "SENDER_EMAIL not configured")

        # Generate OTP
        otp = str(random.randint(100000, 999999))
        expiry = int(time.time()) + 300

        otp_table.put_item({
            "email": email,
            "otp": otp,
            "expiry": expiry,
            "used": False
        })

        # Send Email
        ses.send_email(
            Source=SENDER,
            Destination={"ToAddresses": [email]},
            Message={
                "Subject": {"Data": "OTP Verification"},
                "Body": {"Text": {"Data": f"Your OTP is {otp}"}}
            }
        )

        return response(200, "OTP sent")

    except Exception as e:
        print(e)
        return response(500, "Server error")


def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": message})
    }
