import json
import boto3
import os
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
votes_table = dynamodb.Table(os.environ["VOTES_TABLE"])


def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }


def lambda_handler(event, context):
    try:
        print("EVENT:", json.dumps(event))

        request_context = event.get("requestContext", {})
        http = request_context.get("http", {})
        method = http.get("method", "")
        path = http.get("path", "")

        # -----------------------------
        # GET ALL RESULTS
        # -----------------------------
        if path == "/results" and method == "GET":
            data = votes_table.scan()

            votes = [
                {"vote": item.get("candidateId")}
                for item in data.get("Items", [])
            ]

            return response(200, votes)

        # -----------------------------
        # GET RESULTS BY electionId + postId
        # -----------------------------
        elif path.startswith("/results/") and method == "GET":
            parts = path.strip("/").split("/")

            # expected: /results/{electionId}/{postId}
            if len(parts) == 3:
                _, electionId, postId = parts

                data = votes_table.query(
                    KeyConditionExpression=Key("PK").eq(f"{electionId}#{postId}")
                )

                result = {}

                for item in data.get("Items", []):
                    candidate = item.get("candidateId")
                    if candidate:
                        result[candidate] = result.get(candidate, 0) + 1

                return response(200, result)

            return response(400, {"message": "Invalid path format"})

        return response(400, {"message": "Invalid request"})

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {"message": "Internal server error"})