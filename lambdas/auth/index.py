import boto3, random, time, os

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
voter_table = dynamodb.Table(os.environ['VOTER_TABLE'])

res = voter_table.get_item(Key={"email": email})

if "Item" not in res:
    return {
        "statusCode": 403,
        "body": json.dumps({"message": "Not a registered voter"})
    }

SENDER = os.environ['SENDER_EMAIL']


def lambda_handler(event, context):
    email = event['email']

    # Check voter exists
    res = voter_table.get_item(Key={'mobile': email})
    if 'Item' not in res:
        return {"status": "rejected"}

    otp = str(random.randint(100000, 999999))

    otp_table.put_item(Item={
        'mobile': email,
        'otp': otp,
        'expiry': int(time.time()) + 300
    })

    ses.send_email(
        Source=SENDER,
        Destination={'ToAddresses': [email]},
        Message={
            'Subject': {'Data': 'Your OTP'},
            'Body': {
                'Text': {'Data': f'Your OTP is {otp}'}
            }
        }
    )

    return {"status": "sent"}
