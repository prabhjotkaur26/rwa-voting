import json
import boto3
import os
import jwt
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
config_table = dynamodb.Table(os.environ['CONFIG_TABLE'])

JWT_SECRET = os.environ.get("JWT_SECRET", "mysecret")


# -----------------------------
# JWT ROLE VALIDATION
# -----------------------------
def get_user_role(event):
    headers = event.get("headers") or {}

    token = headers.get("Authorization") or headers.get("authorization")

    if not token:
        return None

    # Remove "Bearer " if present
    if token.startswith("Bearer "):
        token = token.replace("Bearer ", "")

    try:
        decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return decoded.get("role")
    except Exception as e:
        print("JWT ERROR:", str(e))
        return None


# -----------------------------
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # ROLE CHECK (SECURE)
        # -----------------------------
        role = get_user_role(event)
        is_admin = role == "admin"

        # -----------------------------
        # PARSE BODY
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

        # Only admin can see before CLOSED
        if not is_admin and status != "CLOSED":
            return {
                "statusCode": 403,
                "body": json.dumps({
                    "message": "Results not available yet"
                })
            }

        # -----------------------------
        # QUERY VOTES
        # -----------------------------
        response = vote_table.query(
            KeyConditionExpression=Key("post_id").eq(post_id)
        )

        votes = response.get("Items", [])

        # -----------------------------
        # COUNT RESULTS
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
