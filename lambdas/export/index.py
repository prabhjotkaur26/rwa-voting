import json, boto3, os, csv

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

table = dynamodb.Table(os.environ['VOTE_TABLE'])
BUCKET = os.environ['BUCKET']

def lambda_handler(event, context):

    res = table.scan()
    items = res.get("Items", [])

    file_path = "/tmp/results.csv"

    with open(file_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["Email", "Post", "Candidate"])

        for i in items:
            writer.writerow([i['email'], i['post_id'], i['candidate_id']])

    s3.upload_file(file_path, BUCKET, "results.csv")

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Exported to S3"})
    }
