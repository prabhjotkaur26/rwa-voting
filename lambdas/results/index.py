import json
import boto3
import os
import jwt
from boto3.dynamodb.conditions import Key

# -----------------------------
# AWS RESOURCES
# -----------------------------
dynamodb = boto3.resource('dynamodb')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
config_table = dynamodb.Table(os.environ['CONFIG_TABLE'])

JWT_SECRET = os.environ.get("JWT_SECRET", "mysecret")


# -----------------------------
# RESPONSE HELPER
# -----------------------------
def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }


# -----------------------------
# JWT ROLE VALIDATION
# -----------------------------
def get_user_role(event):
    headers = event.get("headers") or {}

    token = headers.get("Authorization") or headers.get("authorization")

    if not token:
        return None

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
        # ROLE CHECK
        # -----------------------------
        role = get_user_role(event)
        is_admin = role == "admin"

        # -----------------------------
        # BODY PARSE
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("post_id") or body.get("postId")

        if not post_id:
            return response(400, {"message": "post_id required"})

        # -----------------------------
        # CHECK ELECTION STATUS
        # -----------------------------
        config = config_table.get_item(Key={"post_id": post_id})
        item = config.get("Item", {})

        status = item.get("status", "ACTIVE")

        # restrict non-admin users
        if not is_admin and status != "CLOSED":
            return response(403, {"message": "Results not available yet"})

        # -----------------------------
        # FETCH VOTES
        # -----------------------------
        result = vote_table.query(
            KeyConditionExpression=Key("post_id").eq(post_id)
        )

        votes = result.get("Items", [])

        # -----------------------------
        # COUNT RESULTS SAFELY
        # -----------------------------
        vote_count = {}

        for v in votes:
            cid = v.get("candidate_id")

            if not cid:
                continue

            vote_count[cid] = vote_count.get(cid, 0) + 1

        # -----------------------------
        # EMPTY RESULT HANDLING
        # -----------------------------
        if not vote_count:
            return response(200, {
                "post_id": post_id,
                "results": {},
                "message": "No votes yet"
            })

        # -----------------------------
        # SUCCESS RESPONSE
        # -----------------------------
        return response(200, {
            "post_id": post_id,
            "results": vote_count
        })

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {
            "message": "Internal server error",
            "error": str(e)
        })
