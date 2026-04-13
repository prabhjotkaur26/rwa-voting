import json, boto3, random, time, os

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

table = dynamodb.Table(os.environ['OTP_TABLE'])

def lambda_handler(event, context):
    body = json.loads(event['body'])
    mobile = body['mobileNumber']

    if not mobile.startswith("+"):
        mobile = "+" + mobile

    otp = str(random.randint(100000, 999999))
    expires = int(time.time()) + 300

    table.put_item(Item={
        "mobileNumber": mobile,
        "otp": otp,
        "expiresAt": expires,
        "used": False
    })

    sns.publish(
        PhoneNumber=mobile,
        Message=f"Your OTP is {otp}"
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "OTP sent"})
    }
