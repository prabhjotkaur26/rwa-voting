import json
import boto3
import jwt
import os
from datetime import datetime

# AWS CLIENTS
dynamodb = boto3.resource("dynamodb", region_name="ap-south-1")
votes_table = dynamodb.Table(os.environ["VOTES_TABLE"])

SECRET = os.environ["JWT_SECRET"]

print("VOTES_TABLE:", os.environ.get("VOTES_TABLE"))
print("JWT_SECRET:", os.environ.get("JWT_SECRET"))
print("Table name:", votes_table.table_name)

def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # AUTH CHECK
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        if not auth or not auth.startswith("Bearer "):
            return response(401, {"message": "Unauthorized"})

        token = auth.split(" ")[1]

        try:
            payload = jwt.decode(token, SECRET, algorithms=["HS256"])
            email = payload["email"]
            print("Decoded email from JWT:", email)
        except jwt.ExpiredSignatureError:
            return response(401, {"message": "Token expired"})
        except jwt.InvalidTokenError:
            return response(401, {"message": "Invalid token"})

        # Parse request body
        body = event.get("body")

        if not body:
            return response(400, {"message": "Request body is required"})

        if isinstance(body, str):
            body = json.loads(body)

        email = body.get("email")
        electionId = body.get("electionId")
        votes = body.get("votes")

        print("Body email:", email, "electionId:", electionId, "votes:", votes)

        if not email or not electionId or not votes:
            return response(400, {"message": "email, electionId, and votes are required"})

        # Submit votes
        for post, candidate in votes.items():
            print("Putting vote for post:", post, "candidate:", candidate)
            votes_table.put_item(
                Item={
                    "PK": f"{electionId}#{post}",
                    "SK": email,
                    "candidateId": candidate,
                    "timestamp": datetime.utcnow().isoformat()
                }
            )

        return response(200, {"message": "Vote submitted successfully"})

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {"message": "Internal server error"})


def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }