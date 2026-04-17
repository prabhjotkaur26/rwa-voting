import json, boto3, random, time, os

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')

table = dynamodb.Table(os.environ['OTP_TABLE'])

SENDER = os.environ['SENDER_EMAIL']

def lambda_handler(event, context):
    body = json.loads(event['body'])
    email = body['email']

    otp = str(random.randint(100000, 999999))
    expiry = int(time.time()) + 300  # 5 min

    # Store OTP in DynamoDB
    table.put_item(Item={
        "email": email,
        "otp": otp,
        "expiry": expiry,
        "used": False
    })

    # Send Email via SES
    ses.send_email(
        Source=SENDER,
        Destination={
            'ToAddresses': [email]
        },
        Message={
            'Subject': {
                'Data': 'Your OTP for Voting'
            },
            'Body': {
                'Text': {
                    'Data': f'Your OTP is {otp}. It will expire in 5 minutes.'
                }
            }
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "OTP sent to email"})
    }
