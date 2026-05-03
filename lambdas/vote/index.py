import json
import boto3
import jwt
import os
from datetime import datetime

dynamodb = boto3.resource("dynamodb", region_name="ap-south-1")
votes_table = dynamodb.Table(os.environ["VOTES_TABLE"])

SECRET = os.environ["JWT_SECRET"]


def lambda_handler(event, context):
    try:
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        if not auth or not auth.startswith("Bearer "):
            return response(401, "Unauthorized")

        token = auth.split(" ")[1]
        payload = jwt.decode(token, SECRET, algorithms=["HS256"])
        email = payload["email"]

        body = json.loads(event.get("body", "{}"))

        electionId = body.get("electionId")
        votes = body.get("votes")

        if not electionId or not votes:
            return response(400, "Missing data")

        # MULTI MEMBERS
        committee = votes.get("committee")

        if not isinstance(committee, list):
            return response(400, "Invalid format")

        for member in committee:
            votes_table.put_item(
                Item={
                    "PK": f"{electionId}#committee",
                    "SK": f"{email}#{member}",
                    "candidateId": member,
                    "email": email,
                    "timestamp": datetime.utcnow().isoformat()
                }
            )

        return response(200, "Vote saved")

    except Exception as e:
        print(e)
        return response(500, "Server error")


def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": message})
    }
