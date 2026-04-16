import json
import boto3
import os
import csv
from io import StringIO, BytesIO
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
config_table = dynamodb.Table(os.environ['CONFIG_TABLE'])

BUCKET = os.environ['BUCKET']


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # ADMIN CHECK
        # -----------------------------
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        if auth != "admin":
            return {
                "statusCode": 403,
                "body": "Admin only"
            }

        # -----------------------------
        # BODY
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("post_id")

        if not post_id:
            return {
                "statusCode": 400,
                "body": "post_id required"
            }

        # -----------------------------
        # GET VOTES
        # -----------------------------
        response = vote_table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key("post_id").eq(post_id)
        )

        votes = response.get("Items", [])

        if not votes:
            return {
                "statusCode": 404,
                "body": "No votes found"
            }

        # -----------------------------
        # COUNT
        # -----------------------------
        result = {}

        for v in votes:
            cid = v["candidate_id"]
            result[cid] = result.get(cid, 0) + 1

        # -----------------------------
        # CSV
        # -----------------------------
        csv_buffer = StringIO()
        writer = csv.writer(csv_buffer)

        writer.writerow(["Candidate ID", "Votes"])

        for cid, count in result.items():
            writer.writerow([cid, count])

        csv_key = f"exports/{post_id}_{int(datetime.utcnow().timestamp())}.csv"

        s3.put_object(
            Bucket=BUCKET,
            Key=csv_key,
            Body=csv_buffer.getvalue()
        )

        # -----------------------------
        # RETURN ONLY CSV (NO PDF for now)
        # -----------------------------
        url = f"https://{BUCKET}.s3.amazonaws.com/{csv_key}"

        return {
            "statusCode": 200,
            "body": json.dumps({
                "csv": url
            })
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal error",
                "error": str(e)
            })
        }
