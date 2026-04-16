import json, boto3, random, time, os

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
voter_table = dynamodb.Table(os.environ['VOTER_TABLE'])

SENDER = os.environ['SENDER_EMAIL']

def lambda_handler(event, context):
    try:
        body = event.get("body")

        # ✅ Handle weird string body
        if isinstance(body, str):
            try:
                body = json.loads(body)
            except:
                return {
                    "statusCode": 400,
                    "body": "Invalid JSON format"
                }

        email = body.get("email") if isinstance(body, dict) else None

        if not email:
            return {
                "statusCode": 400,
                "body": "Email required"
            }

        # ✅ Check voter
        res = voter_table.get_item(Key={'email': email})
        if 'Item' not in res:
            return {
                "statusCode": 403,
                "body": json.dumps({"message": "Not a registered voter"})
            }

        otp = str(random.randint(100000, 999999))

        otp_table.put_item(Item={
            "email": email,
            "otp": otp,
            "expiry": int(time.time()) + 300,
            "used": False
        })

        ses.send_email(
            Source=SENDER,
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'OTP'},
                'Body': {'Text': {'Data': f'Your OTP is {otp}'}}
            }
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "OTP sent"})
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "body": str(e)
        }
