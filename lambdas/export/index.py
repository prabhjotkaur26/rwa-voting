import json
import boto3
import os
import csv
from io import StringIO
from datetime import datetime
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
BUCKET = os.environ['BUCKET']


def lambda_handler(event, context):

    headers = event.get("headers") or {}
    auth = headers.get("Authorization") or headers.get("authorization")

    # basic admin check (you can upgrade later to JWT)
    if auth != "admin":
        return {
            "statusCode": 403,
            "body": json.dumps({"message": "Admin only"})
        }

    body = event.get("body") or "{}"
    if isinstance(body, str):
        body = json.loads(body)

    post_id = body.get("post_id")

    if not post_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "post_id required"})
        }

    # fetch votes
    response = vote_table.query(
        KeyConditionExpression=Key("post_id").eq(post_id)
    )

    votes = response.get("Items", [])

    if not votes:
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "No votes found"})
        }

    # count votes
    result = {}

    for v in votes:
        cid = v["candidate_id"]
        result[cid] = result.get(cid, 0) + 1

    # create CSV
    csv_buffer = StringIO()
    writer = csv.writer(csv_buffer)
    writer.writerow(["Candidate ID", "Votes"])

    for cid, count in result.items():
        writer.writerow([cid, count])

    # S3 KEY
    csv_key = f"exports/{post_id}_{int(datetime.utcnow().timestamp())}.csv"

    # ✅ UPLOAD TO S3 (IMPORTANT PART)
    s3.put_object(
        Bucket=BUCKET,
        Key=csv_key,
        Body=csv_buffer.getvalue(),
        ContentType="text/csv"
    )

    # ✅ RETURN FILE KEY (NOT URL)
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Export successful",
            "file_key": csv_key
        })
    }
