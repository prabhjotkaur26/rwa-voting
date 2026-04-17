import json, boto3, random, time, os

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
voter_table = dynamodb.Table(os.environ['VOTER_TABLE'])

SENDER = os.environ['SENDER_EMAIL']

def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        body = event.get("body")

        # ✅ Strong body parsing
        if isinstance(body, str):
            try:
                body = json.loads(body)
            except:
                # Try extracting JSON manually if malformed
                if "email" in body:
                    import re
                    match = re.search(r'"email"\s*:\s*"([^"]+)"', body)
                    if match:
                        body = {"email": match.group(1)}
                    else:
                        return {
                            "statusCode": 400,
                            "body": "Invalid request format"
                        }
                else:
                    return {
                        "statusCode": 400,
                        "body": "Invalid JSON format"
                    }

        if not isinstance(body, dict):
            return {
                "statusCode": 400,
                "body": "Invalid body"
            }

        email = body.get("email")

        if not email:
            return {
                "statusCode": 400,
                "body": "Email required"
            }

        # ✅ Check voter exists
        res = voter_table.get_item(Key={'email': email})
        if 'Item' not in res:
            return {
                "statusCode": 403,
                "body": json.dumps({"message": "Not a registered voter"})
            }

        # ✅ Generate OTP
        otp = str(random.randint(100000, 999999))
        expiry = int(time.time()) + 300

        # ✅ Store OTP (overwrite old)
        otp_table.put_item(Item={
            "email": email,
            "otp": otp,
            "expiry": expiry,
            "used": False
        })

        # ✅ Send email
        ses.send_email(
            Source=SENDER,
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'Your OTP'},
                'Body': {
                    'Text': {
                        'Data': f'Your OTP is {otp}. Valid for 5 minutes.'
                    }
                }
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
