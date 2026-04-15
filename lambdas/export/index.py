import boto3, csv, os

s3 = boto3.client('s3')

def lambda_handler(event, context):

    file = "/tmp/results.csv"

    with open(file, "w") as f:
        writer = csv.writer(f)
        writer.writerow(["Post", "Candidate", "Votes"])

    s3.upload_file(file, os.environ['BUCKET'], "results.csv")

    return {"statusCode": 200, "body": "Export ready"}
