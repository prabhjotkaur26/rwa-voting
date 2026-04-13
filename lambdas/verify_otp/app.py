import json, boto3, os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['OTP_TABLE'])

def lambda_handler(event, context):
    body = json.loads(event['body'])
    mobile = body['mobileNumber']
    otp = body['otp']

    res = table.get_item(Key={"mobileNumber": mobile})

    if "Item" not in res:
        return {"statusCode": 400, "body": "Invalid"}

    item = res["Item"]

    if item["used"] or item["otp"] != otp:
        return {"statusCode": 400, "body": "Invalid OTP"}

    table.update_item(
        Key={"mobileNumber": mobile},
        UpdateExpression="SET used = :u",
        ExpressionAttributeValues={":u": True}
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"token": mobile})
    }
