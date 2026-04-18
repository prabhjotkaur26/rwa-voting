import boto3
import csv
import urllib.parse

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('voter-registry')

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    file_obj = s3.get_object(Bucket=bucket, Key=key)
    lines = file_obj['Body'].read().decode('utf-8').split()

    reader = csv.DictReader(lines)

    for row in reader:
        table.put_item(Item={
            "email": row["email"],
            "name": row["name"],
            "flatNumber": row["flatNumber"],
            "voterStatus": row["voterStatus"]
        })

    return {
        "statusCode": 200,
        "message": "CSV processed successfully"
    }
