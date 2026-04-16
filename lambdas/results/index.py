import json
import boto3
import os
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
config_table = dynamodb.Table(os.environ['CONFIG_TABLE'])


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # SIMPLE ADMIN CHECK (NO JWT)
        # -----------------------------
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        is_admin = auth == "admin"

        # -----------------------------
        # BODY PARSE
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("postId") or body.get("post_id")

        if not post_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "post_id required"})
            }

        # -----------------------------
        # CHECK ELECTION STATUS
        # -----------------------------
        config = config_table.get_item(Key={"post_id": post_id})
        item = config.get("Item", {})

        status = item.get("status", "ACTIVE")

        if not is_admin and status != "CLOSED":
            return {
                "statusCode": 403,
                "body": json.dumps({"message": "Results not available yet"})
            }

        # -----------------------------
        # QUERY VOTES (CORRECT)
        # -----------------------------
        response = vote_table.query(
            KeyConditionExpression=Key("post_id").eq(post_id)
        )

        votes = response.get("Items", [])

        # -----------------------------
        # COUNT VOTES
        # -----------------------------
        result = {}

        for v in votes:
            cid = v["candidate_id"]
            result[cid] = result.get(cid, 0) + 1

        return {
            "statusCode": 200,
            "body": json.dumps({
                "post_id": post_id,
                "results": result
            })
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error",
                "error": str(e)
            })
        }
