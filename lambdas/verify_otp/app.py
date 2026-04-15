import json, boto3, os, time

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['OTP_TABLE'])

def lambda_handler(event, context):
    body = json.loads(event['body'])

    email = body['email']
    otp = body['otp']

    # Fetch OTP record
    res = table.get_item(Key={"email": email})

    if "Item" not in res:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid request"})
        }

    item = res["Item"]

    # Check OTP match
    if item["otp"] != otp:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid OTP"})
        }

    # Check expiry (IMPORTANT 🔐)
    if item["expiry"] < int(time.time()):
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "OTP expired"})
        }

    # Check if already used
    if item.get("used", False):
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "OTP already used"})
        }

    # Mark OTP as used
    table.update_item(
        Key={"email": email},
        UpdateExpression="SET used = :u",
        ExpressionAttributeValues={":u": True}
    )

    # Return token (basic version)
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Verified",
            "token": email
        })
    }
