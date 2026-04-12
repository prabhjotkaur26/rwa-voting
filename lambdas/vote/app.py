import boto3
import os
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):

    body = json.loads(event['body'])

    voter_id = body["voterId"]
    election_id = body["electionId"]
    post = body["post"]
    candidate_id = body["candidateId"]

    pk = f"VOTER#{voter_id}"
    sk = f"{election_id}#{post}"

    try:
        table.put_item(
            Item={
                "PK": pk,
                "SK": sk,
                "candidateId": candidate_id,
                "time": str(datetime.utcnow())
            },
            ConditionExpression="attribute_not_exists(PK)"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Vote success"})
        }

    except Exception:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Already voted"})
        }
