import boto3
import csv
import urllib.parse
import os
from io import StringIO

# AWS clients
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

table = dynamodb.Table(os.environ['VOTER_TABLE'])


def lambda_handler(event, context):

    print("EVENT RECEIVED:", event)

    try:
        # -----------------------------
        # SAFE EVENT PARSING
        # -----------------------------
        record = event['Records'][0]

        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])

        print(f"Bucket: {bucket}, Key: {key}")

        # -----------------------------
        # FETCH FILE
        # -----------------------------
        file_obj = s3.get_object(Bucket=bucket, Key=key)
        body = file_obj['Body'].read().decode('utf-8')

        # -----------------------------
        # PARSE CSV
        # -----------------------------
        csv_data = StringIO(body)
        reader = csv.DictReader(csv_data)

        count = 0

        # -----------------------------
        # INSERT INTO DYNAMODB
        # -----------------------------
        for row in reader:

            email = (row.get("email") or "").strip().lower()

            if not email:
                print("Skipping row (missing email):", row)
                continue

            try:
                table.put_item(
                    Item={
                        "email": email,
                        "name": row.get("name", "").strip(),
                        "flatNumber": row.get("flatNumber", "").strip(),
                        "voterStatus": row.get("voterStatus", "ACTIVE").strip()
                    }
                )
                count += 1

            except Exception as db_error:
                print("DynamoDB insert failed for row:", row)
                print(str(db_error))

        print(f"SUCCESS: Inserted {count} records")

        return {
            "statusCode": 200,
            "body": f"CSV processed successfully. Inserted {count} records."
        }

    except Exception as e:
        print("FATAL ERROR:", str(e))

        return {
            "statusCode": 500,
            "body": f"Error processing CSV: {str(e)}"
        }
