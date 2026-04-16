import json, boto3, os, time, jwt

dynamodb = boto3.resource('dynamodb')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])

JWT_SECRET = os.environ['JWT_SECRET']

def lambda_handler(event, context):
    try:
        body = event.get("body")

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")
        otp = body.get("otp")

        if not email or not otp:
            return {
                "statusCode": 400,
                "body": "Email and OTP required"
            }

        # ✅ Fetch OTP
        res = otp_table.get_item(Key={"email": email})

        if "Item" not in res:
            return {
                "statusCode": 400,
                "body": "Invalid OTP"
            }

        item = res["Item"]

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
        otp_table.update_item(
            Key={"email": email},
            UpdateExpression="SET used = :u",
            ExpressionAttributeValues={":u": True}
        )

        # ✅ Generate JWT
        token = jwt.encode(
            {"email": email, "exp": int(time.time()) + 3600},
            JWT_SECRET,
            algorithm="HS256"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"token": token})
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "body": str(e)
        }
