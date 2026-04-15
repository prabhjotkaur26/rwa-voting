import json, boto3, os, jwt, time

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['OTP_TABLE'])

SECRET = os.environ['JWT_SECRET']

def lambda_handler(event, context):

    body = event.get('body')
    if isinstance(body, str):
        body = json.loads(body)

    email = body['email']
    otp = body['otp']

    res = table.get_item(Key={'email': email})

    if 'Item' not in res:
        return {"statusCode": 400, "body": "Invalid"}

    item = res['Item']

    if item['used'] or item['otp'] != otp or item['expiry'] < int(time.time()):
        return {"statusCode": 400, "body": "Invalid OTP"}

    table.update_item(
        Key={'email': email},
        UpdateExpression="SET used = :u",
        ExpressionAttributeValues={":u": True}
    )

    token = jwt.encode({"email": email}, SECRET, algorithm="HS256")

    return {
        "statusCode": 200,
        "body": json.dumps({"token": token})
    }
