import boto3
import csv
import urllib.parse
import os
from io import StringIO

# -----------------------------
# AWS CLIENTS
# -----------------------------
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Use Terraform env variable (IMPORTANT FIX)
table = dynamodb.Table(os.environ['VOTER_TABLE'])


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # GET S3 DETAILS
        # -----------------------------
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(
            event['Records'][0]['s3']['object']['key']
        )

        # -----------------------------
        # READ FILE FROM S3
        # -----------------------------
        file_obj = s3.get_object(Bucket=bucket, Key=key)
        body = file_obj['Body'].read().decode('utf-8')

        # FIX: proper CSV parsing
        csv_data = StringIO(body)
        reader = csv.DictReader(csv_data)

        # -----------------------------
        # INSERT INTO DYNAMODB
        # -----------------------------
        for row in reader:

            email = row.get("email", "").strip().lower()

            if not email:
                continue

            table.put_item(
                Item={
                    "email": email,
                    "name": row.get("name", ""),
                    "flatNumber": row.get("flatNumber", ""),
                    "voterStatus": row.get("voterStatus", "ACTIVE")
                }
            )

        return {
            "statusCode": 200,
            "body": "CSV processed successfully"
        }

    except Exception as e:
        print("ERROR:", str(e))

        return {
            "statusCode": 500,
            "body": f"Error processing CSV: {str(e)}"
        }
