import boto3
import os
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        # Parse request body
        if "body" not in event:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Invalid request: no body"})
            }

       # Parse request body safely
body = {}

if event.get("body"):
    if isinstance(event["body"], str):
        body = json.loads(event["body"])
    else:
        body = event["body"]

        # Validate input
        voter_id = body.get("voterId")
        election_id = body.get("electionId")
        post = body.get("post")
        candidate_id = body.get("candidateId")

        if not all([voter_id, election_id, post, candidate_id]):
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Missing required fields"})
            }

        # Create keys
        pk = f"VOTER#{voter_id}"
        sk = f"{election_id}#{post}"

        # Save vote (prevent duplicate)
        table.put_item(
            Item={
                "PK": pk,
                "SK": sk,
                "candidateId": candidate_id,
                "time": datetime.utcnow().isoformat()
            },
            ConditionExpression="attribute_not_exists(PK)"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Vote recorded successfully"})
        }

    except Exception as e:
        print("ERROR:", str(e))  # logs CloudWatch me jayega

        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": "Already voted or error occurred",
                "error": str(e)
            })
        }
