import json, boto3, random, time, os

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
voter_table = dynamodb.Table(os.environ['VOTER_TABLE'])

SENDER = os.environ['SENDER_EMAIL']


def lambda_handler(event, context):

    print("EVENT:", event)  # Debug

    # Parse body safely
    body = event.get('body')

    if isinstance(body, str):
        body = json.loads(body)

    email = body['email']

    # ✅ Check voter exists
    res = voter_table.get_item(Key={'email': email})

    if 'Item' not in res:
        return {
            "statusCode": 403,
            "body": json.dumps({"message": "Not a registered voter"})
        }

    # ✅ Generate OTP
    otp = str(random.randint(100000, 999999))

    # ✅ Store OTP
    otp_table.put_item(Item={
        'email': email,
        'otp': otp,
        'expiry': int(time.time()) + 300,
        'used': False
    })

    # ✅ Send email via SES
    ses.send_email(
        Source=SENDER,
        Destination={'ToAddresses': [email]},
        Message={
            'Subject': {'Data': 'Your OTP'},
            'Body': {
                'Text': {'Data': f'Your OTP is {otp}. It expires in 5 minutes.'}
            }
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "OTP sent"})
    }
