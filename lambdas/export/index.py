import json
import boto3
import os
import csv
from io import StringIO
from datetime import datetime
from boto3.dynamodb.conditions import Key

# -----------------------------
# AWS CLIENTS
# -----------------------------
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
BUCKET = os.environ['BUCKET']


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


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # ADMIN CHECK (TEMP)
        # -----------------------------
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        if auth != "admin-secret-key":
            return response(403, {"message": "Admin only"})

        # -----------------------------
        # PARSE BODY
        # -----------------------------
        body = event.get("body") or "{}"
        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("post_id")

        if not post_id:
            return response(400, {"message": "post_id required"})

        # -----------------------------
        # FETCH VOTES
        # -----------------------------
        result = vote_table.query(
            KeyConditionExpression=Key("post_id").eq(post_id)
        )

        votes = result.get("Items", [])

        if not votes:
            return response(404, {"message": "No votes found"})

        # -----------------------------
        # COUNT VOTES
        # -----------------------------
        vote_count = {}

        for v in votes:
            cid = v.get("candidate_id")

            if not cid:
                continue

            vote_count[cid] = vote_count.get(cid, 0) + 1

        # -----------------------------
        # CREATE CSV
        # -----------------------------
        csv_buffer = StringIO()
        writer = csv.writer(csv_buffer)

        writer.writerow(["Candidate ID", "Votes"])

        for cid, count in vote_count.items():
            writer.writerow([cid, count])

        # -----------------------------
        # S3 UPLOAD
        # -----------------------------
        csv_key = f"exports/{post_id}_{int(datetime.utcnow().timestamp())}.csv"

        s3.put_object(
            Bucket=BUCKET,
            Key=csv_key,
            Body=csv_buffer.getvalue(),
            ContentType="text/csv"
        )

        # -----------------------------
        # RESPONSE
        # -----------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": "Export successful",
                "file_key": csv_key
            })
        }

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {"message": "Internal server error"})
