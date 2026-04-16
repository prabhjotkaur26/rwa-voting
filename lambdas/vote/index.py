import json
import boto3
import os
import jwt
from datetime import datetime

dynamodb = boto3.resource('dynamodb')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])

JWT_SECRET = os.environ['JWT_SECRET']


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # 1. HEADERS SAFE READ
        # -----------------------------
        headers = event.get("headers", {})

        auth_header = headers.get("Authorization") or headers.get("authorization")

        if not auth_header:
            return {
                "statusCode": 401,
                "body": json.dumps({"message": "Missing token"})
            }

        token = auth_header.replace("Bearer ", "").strip()

        # -----------------------------
        # 2. JWT VERIFY
        # -----------------------------
        try:
            decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
            email = decoded["email"]
        except Exception as e:
            return {
                "statusCode": 401,
                "body": json.dumps({"message": f"Invalid token: {str(e)}"})
            }

        # -----------------------------
        # 3. BODY PARSE SAFE
        # -----------------------------
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

        # -----------------------------
        # 4. UNIQUE VOTE KEY
        # -----------------------------
        vote_id = f"{email}#{post_id}"

        # -----------------------------
        # 5. INSERT VOTE (NO DUPLICATE)
        # -----------------------------
        vote_table.put_item(
    Item={
        "post_id": post_id,
        "voter_id": email,
        "candidate_id": candidate_id,
        "timestamp": datetime.utcnow().isoformat()
    }
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
                "body": json.dumps({"message": "You already voted for this post"})
            }

        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Internal server error", "error": str(e)})
        }
