import jwt, os

SECRET = os.environ['JWT_SECRET']

def lambda_handler(event, context):

    headers = event['headers']
    token = headers.get("Authorization")

    try:
        decoded = jwt.decode(token, SECRET, algorithms=["HS256"])
        email = decoded['email']
    except:
        return {"statusCode": 401, "body": "Unauthorized"}

    body = json.loads(event['body'])

    post_id = body['post_id']
    candidate_id = body['candidate_id']

    table.put_item(
        Item={
            "post_id": post_id,
            "voter_id": email,
            "candidate_id": candidate_id
        },
        ConditionExpression="attribute_not_exists(voter_id)"
    )

    return {"statusCode": 200, "body": "Vote recorded"}
