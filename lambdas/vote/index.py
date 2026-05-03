import json
import boto3
import jwt
import os
from datetime import datetime

# AWS CLIENTS
dynamodb = boto3.resource("dynamodb", region_name="ap-south-1")
votes_table = dynamodb.Table(os.environ["VOTES_TABLE"])

SECRET = os.environ["JWT_SECRET"]

def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # AUTH CHECK (JWT)
        # -----------------------------
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        if not auth or not auth.startswith("Bearer "):
            return response(401, {"message": "Unauthorized"})

        token = auth.split(" ")[1]

        try:
            payload = jwt.decode(token, SECRET, algorithms=["HS256"])
            email = payload["email"]  # ✅ ONLY TRUST THIS
            print("JWT email:", email)
        except jwt.ExpiredSignatureError:
            return response(401, {"message": "Token expired"})
        except jwt.InvalidTokenError:
            return response(401, {"message": "Invalid token"})

        # -----------------------------
        # PARSE BODY
        # -----------------------------
        body = event.get("body")

        if not body:
            return response(400, {"message": "Request body is required"})

        if isinstance(body, str):
            body = json.loads(body)

        electionId = body.get("electionId")
        votes = body.get("votes")

        if not electionId or not votes:
            return response(400, {"message": "electionId and votes are required"})

        print("Votes received:", votes)

        # -----------------------------
        # HANDLE VOTING (MULTI MEMBERS)
        # -----------------------------
        for post, candidates in votes.items():

            # If single value → convert to list
            if isinstance(candidates, str):
                candidates = [candidates]

            # If not list → error
            if not isinstance(candidates, list):
                return response(400, {"message": f"Invalid format for {post}"})

            for candidate in candidates:
                votes_table.put_item(
                    Item={
                        "PK": f"{electionId}#{post}",
                        "SK": f"{email}#{candidate}",  # ✅ prevents overwrite
                        "email": email,
                        "candidateId": candidate,
                        "timestamp": datetime.utcnow().isoformat()
                    }
                )

        return response(200, {"message": "Vote submitted successfully"})

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {"message": "Internal server error"})


# -----------------------------
# RESPONSE HELPER
# -----------------------------
def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
