import boto3, os, random, time

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

otp_table = dynamodb.Table(os.environ['OTP_TABLE'])
voter_table = dynamodb.Table(os.environ['VOTER_TABLE'])

def lambda_handler(event, context):
    mobile = event['mobile']

    res = voter_table.get_item(Key={'mobile': mobile})
    if 'Item' not in res:
        return {"status": "rejected"}

    otp = str(random.randint(100000, 999999))

    otp_table.put_item(Item={
        'mobile': mobile,
        'otp': otp,
        'expiry': int(time.time()) + 300
    })

    sns.publish(
        PhoneNumber=mobile,
        Message=f"Your OTP is {otp}"
    )

    return {"status": "sent"}
