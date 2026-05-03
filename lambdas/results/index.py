import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
votes_table = dynamodb.Table(os.environ["VOTES_TABLE"])


def lambda_handler(event, context):
    try:
        data = votes_table.scan()

        result = {}

        for item in data.get("Items", []):
            candidate = item.get("candidateId")
            if candidate:
                result[candidate] = result.get(candidate, 0) + 1

        return response(200, result)

    except Exception as e:
        print(e)
        return response(500, "Error")


def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
