import boto3
import csv
import urllib.parse
import os
from io import StringIO

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

table = dynamodb.Table(os.environ['VOTER_TABLE'])


def lambda_handler(event, context):

    print("EVENT RECEIVED:", event)

    try:
        record = event['Records'][0]

        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])

        print(f"Bucket: {bucket}, Key: {key}")

        file_obj = s3.get_object(Bucket=bucket, Key=key)
        body = file_obj['Body'].read().decode('utf-8')

        csv_data = StringIO(body)
        reader = csv.DictReader(csv_data)

        count = 0

        # ✅ Correct placement
        with table.batch_writer() as batch:
            for row in reader:
                try:
                    email = (row.get("email") or "").strip().lower()

                    if not email:
                        print(f"Skipping row: {row}")
                        continue

                    item = {
                        "email": email,
                        "name": (row.get("name") or "").strip(),
                        "flatNumber": (row.get("flatNumber") or "").strip(),
                        "voterStatus": (row.get("voterStatus") or "ACTIVE").strip()
                    }

                    batch.put_item(Item=item)
                    count += 1

                except Exception as db_error:
                    print("Insert failed:", row)
                    print(str(db_error))

        print(f"SUCCESS: Inserted {count} records")

        return {
            "statusCode": 200,
            "body": f"Inserted {count} records"
        }

    except Exception as e:
        print("FATAL ERROR:", str(e))

        return {
            "statusCode": 500,
            "body": str(e)
        }
