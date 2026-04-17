<<<<<<< HEAD
import json, boto3, os, time, jwt
=======
import json
import boto3
import os
import time
import jwt
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c

dynamodb = boto3.resource('dynamodb')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
<<<<<<< HEAD

JWT_SECRET = os.environ['JWT_SECRET']

def lambda_handler(event, context):
    try:
        body = event.get("body")
=======
JWT_SECRET = os.environ['JWT_SECRET']


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        body = event.get("body") or "{}"
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")
        otp = body.get("otp")

        if not email or not otp:
            return {
                "statusCode": 400,
<<<<<<< HEAD
                "body": "Email and OTP required"
            }

        # ✅ Fetch OTP
=======
                "body": json.dumps({"message": "Email and OTP required"})
            }

        # -----------------------------
        # FETCH OTP
        # -----------------------------
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c
        res = otp_table.get_item(Key={"email": email})

        if "Item" not in res:
            return {
                "statusCode": 400,
<<<<<<< HEAD
                "body": "Invalid OTP"
=======
                "body": json.dumps({"message": "Invalid OTP"})
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c
            }

        item = res["Item"]

<<<<<<< HEAD
        # ❌ Expired
        if int(time.time()) > item["expiry"]:
            return {
                "statusCode": 400,
                "body": "OTP expired"
            }

        # ❌ Wrong or used
        if item["otp"] != otp or item.get("used"):
            return {
                "statusCode": 400,
                "body": "Invalid OTP"
            }

        # ✅ Mark used
=======
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
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c
        otp_table.update_item(
            Key={"email": email},
            UpdateExpression="SET used = :u",
            ExpressionAttributeValues={":u": True}
        )

<<<<<<< HEAD
        # ✅ Generate JWT
        token = jwt.encode(
            {"email": email, "exp": int(time.time()) + 3600},
=======
        # -----------------------------
        # ADMIN LOGIC
        # -----------------------------
        is_admin = True if email == "prabhjot582004@gmail.com" else False

        # -----------------------------
        # GENERATE JWT
        # -----------------------------
        token = jwt.encode(
            {
                "email": email,
                "isAdmin": is_admin,
                "exp": int(time.time()) + 3600
            },
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c
            JWT_SECRET,
            algorithm="HS256"
        )

        return {
            "statusCode": 200,
<<<<<<< HEAD
            "body": json.dumps({"token": token})
=======
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "token": token,
                "isAdmin": is_admin
            })
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c
        }

    except Exception as e:
        print("ERROR:", str(e))
<<<<<<< HEAD
        return {
            "statusCode": 500,
            "body": str(e)
=======

        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error",
                "error": str(e)
            })
>>>>>>> 415f187d4d706d35862c6f526b70dd8bbf14710c
        }
