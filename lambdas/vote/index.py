import json
import boto3
import os
import jwt
from datetime import datetime
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
JWT_SECRET = os.environ['JWT_SECRET']


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        headers = event.get("headers") or {}
        auth_header = headers.get("Authorization") or headers.get("authorization")

        if not auth_header:
            return {
                "statusCode": 401,
                "body": json.dumps({"message": "Missing token"})
            }

        token = auth_header.replace("Bearer ", "").strip()

        try:
            decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
            email = decoded.get("email")

            if not email:
                return {
                    "statusCode": 401,
                    "body": json.dumps({"message": "Invalid token"})
                }

        except Exception as e:
            return {
                "statusCode": 401,
                "body": json.dumps({"message": f"Invalid token: {str(e)}"})
            }

        # Body parsing
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("postId") or body.get("post_id")
        candidate_id = body.get("candidateId") or body.get("candidate_id")

        if not post_id or not candidate_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "postId and candidateId required"})
            }

        # Insert vote with duplicate protection
        try:
            vote_table.put_item(
                Item={
                    "post_id": post_id,
                    "voter_id": email,
                    "candidate_id": candidate_id,
                    "timestamp": datetime.utcnow().isoformat()
                },
                ConditionExpression="attribute_not_exists(post_id)"
            )

        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                return {
                    "statusCode": 400,
                    "body": json.dumps({"message": "You already voted for this post"})
                }
            else:
                raise e

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Vote cast successfully"})
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error",
                "error": str(e)
            })
        }
