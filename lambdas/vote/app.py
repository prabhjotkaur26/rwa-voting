import boto3
import os
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # Safe body parsing
        body = {}
        if event.get("body"):
            if isinstance(event["body"], str):
                body = json.loads(event["body"])
            else:
                body = event["body"]

        voter_id = body.get("voterId")
        election_id = body.get("electionId")
        post = body.get("post")
        candidate_id = body.get("candidateId")

        if not voter_id or not election_id or not post or not candidate_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Missing required fields"})
            }

        pk = f"VOTER#{voter_id}"
        sk = f"{election_id}#{post}"

        # ✅ FIXED CONDITION (IMPORTANT)
        table.put_item(
            Item={
                "PK": pk,
                "SK": sk,
                "candidateId": candidate_id,
                "time": datetime.utcnow().isoformat()
            },
            ConditionExpression="attribute_not_exists(SK)"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Vote recorded successfully"})
        }

    except Exception as e:
        print("ERROR:", str(e))

        # ✅ HANDLE DUPLICATE VOTE
        if "ConditionalCheckFailedException" in str(e):
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "You already voted for this post"})
            }

        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal Server Error",
                "error": str(e)
            })
        }
