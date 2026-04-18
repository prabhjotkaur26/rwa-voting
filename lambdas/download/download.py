import json
import boto3
import os

s3 = boto3.client('s3')
BUCKET = os.environ['BUCKET']


# -----------------------------
# RESPONSE HELPER
# -----------------------------
def response(status, body, headers=None):
    return {
        "statusCode": status,
        "headers": headers or {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body) if isinstance(body, dict) else body
    }


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # ADMIN AUTH (TEMP - replace with JWT later)
        # -----------------------------
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        if auth != "admin-secret-key":
            return response(403, {"message": "Admin only"})

        # -----------------------------
        # GET FILE KEY
        # -----------------------------
        params = event.get("queryStringParameters") or {}
        key = params.get("key")

        if not key:
            return response(400, {"message": "Missing key"})

        # -----------------------------
        # FETCH FROM S3
        # -----------------------------
        obj = s3.get_object(Bucket=BUCKET, Key=key)
        data = obj["Body"].read().decode("utf-8")

        # -----------------------------
        # RETURN FILE
        # -----------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "text/csv",
                "Access-Control-Allow-Origin": "*",
                "Content-Disposition": f"attachment; filename={key.split('/')[-1]}"
            },
            "body": data
        }

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {"message": "Internal server error"})
