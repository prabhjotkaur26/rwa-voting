import json
import boto3
import os

s3 = boto3.client('s3')
BUCKET = os.environ['BUCKET']


def lambda_handler(event, context):

    headers = event.get("headers") or {}
    auth = headers.get("Authorization") or headers.get("authorization")

    if auth != "admin":
        return {
            "statusCode": 403,
            "body": json.dumps({"message": "Admin only"})
        }

    key = event.get("queryStringParameters", {}).get("key")

    if not key:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Missing key"})
        }

    obj = s3.get_object(Bucket=BUCKET, Key=key)
    data = obj["Body"].read().decode("utf-8")

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/csv",
            "Content-Disposition": f"attachment; filename={key.split('/')[-1]}"
        },
        "body": data
    }
