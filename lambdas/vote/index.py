import json, boto3, os, jwt

dynamodb = boto3.resource('dynamodb')
vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])

JWT_SECRET = os.environ['JWT_SECRET']

def lambda_handler(event, context):
    try:
        # ✅ Get token from headers
        headers = event.get("headers", {})
        token = headers.get("Authorization")

        if not token:
            return {
                "statusCode": 401,
                "body": "Unauthorized"
            }

        # ✅ Decode JWT
        decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        email = decoded["email"]

        # ✅ Parse body
        body = event.get("body")
        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("postId")
        candidate_id = body.get("candidateId")

        if not post_id or not candidate_id:
            return {
                "statusCode": 400,
                "body": "postId and candidateId required"
            }

        # ✅ Unique key → email + post
        vote_id = f"{email}#{post_id}"

        # ✅ Prevent duplicate vote
        vote_table.put_item(
            Item={
                "voteId": vote_id,
                "email": email,
                "postId": post_id,
                "candidateId": candidate_id
            },
            ConditionExpression="attribute_not_exists(voteId)"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Vote cast successfully"})
        }

    except Exception as e:
        print("ERROR:", str(e))

        if "ConditionalCheckFailedException" in str(e):
            return {
                "statusCode": 400,
                "body": "You have already voted for this post"
            }

        return {
            "statusCode": 500,
            "body": str(e)
        }
