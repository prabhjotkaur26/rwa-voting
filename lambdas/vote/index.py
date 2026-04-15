import json, boto3, os, jwt

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['VOTE_TABLE'])

SECRET = os.environ['JWT_SECRET']

def lambda_handler(event, context):

    headers = event.get("headers", {})
    token = headers.get("Authorization")

    try:
        data = jwt.decode(token, SECRET, algorithms=["HS256"])
        email = data['email']
    except:
        return {"statusCode": 401, "body": "Unauthorized"}

    body = event.get('body')
    if isinstance(body, str):
        body = json.loads(body)

    post_id = body['post_id']
    candidate_id = body['candidate_id']

    try:
        table.put_item(
            Item={
                "email": email,
                "post_id": post_id,
                "candidate_id": candidate_id
            },
            ConditionExpression="attribute_not_exists(email)"
        )
    except:
        return {"statusCode": 400, "body": "Already voted"}

    return {
        "statusCode": 200,
        "body": "Vote recorded"
    }
