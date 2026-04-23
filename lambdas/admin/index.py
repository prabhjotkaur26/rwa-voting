import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')

voter_table = dynamodb.Table(os.environ['VOTER_TABLE'])
config_table = dynamodb.Table(os.environ['CONFIG_TABLE'])


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
# MAIN HANDLER
# -----------------------------
def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # BASIC AUTH CHECK (TEMP SAFE VERSION)
        # -----------------------------
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        # ⚠️ NOTE: replace with JWT later (IMPORTANT)
        if auth != "admin-secret-key":
            return response(403, {"message": "Admin only"})

        # -----------------------------
        # BODY PARSE
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        action = body.get("action")

        # ====================================================
        # ADD VOTERS
        # ====================================================
        if action == "add_voters":

            voters = body.get("voters", [])

            if not voters:
                return response(400, {"message": "voters list required"})

            for v in voters:
                email = v.get("email")

                if not email:
                    continue

                email = email.strip().lower()

                voter_table.put_item(
                    Item={
                        "email": email,
                        "is_verified": True
                    }
                )

            return response(200, {"message": "Voters added successfully"})

        # ====================================================
        # CREATE ELECTION
        # ====================================================
        elif action == "create_election":

            post_id = body.get("post_id")
            candidates = body.get("candidates", [])

            if not post_id or not candidates:
                return response(400, {"message": "post_id and candidates required"})

            if len(candidates) > 7:
                return response(400, {"message": "Max 7 candidates allowed"})

            # prevent overwrite
            existing = config_table.get_item(Key={"post_id": post_id})
            if "Item" in existing:
                return response(400, {"message": "Election already exists"})

            config_table.put_item(
                Item={
                    "post_id": post_id,
                    "candidates": candidates,
                    "status": "CREATED"
                }
            )

            return response(200, {"message": "Election created"})

        # ====================================================
        # ADD CANDIDATE
        # ====================================================
        elif action == "add_candidate":

            post = body.get("post")
            candidate = body.get("candidate")

            if not post or not candidate:
                return response(400, {"message": "post and candidate required"})

            # Get existing
            res = config_table.get_item(Key={"post_id": post})

            if "Item" not in res:
                return response(400, {"message": "Election not found"})

            item = res["Item"]
            candidates = item.get("candidates", [])

            if candidate in candidates:
                return response(400, {"message": "Candidate already exists"})

            if len(candidates) >= 7:
                return response(400, {"message": "Max 7 candidates allowed"})

            candidates.append(candidate)

            config_table.update_item(
                Key={"post_id": post},
                UpdateExpression="SET candidates = :val",
                ExpressionAttributeValues={":val": candidates}
            )

            return response(200, {"message": "Candidate added"})

        # ====================================================
        # START ELECTION
        # ====================================================
        elif action == "start_election":

            post_id = body.get("post_id")

            if not post_id:
                return response(400, {"message": "post_id required"})

            config_table.update_item(
                Key={"post_id": post_id},
                UpdateExpression="SET #s = :val",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":val": "ACTIVE"}
            )

            return response(200, {"message": "Election started"})

        # ====================================================
        # CLOSE ELECTION
        # ====================================================
        elif action == "close_election":

            post_id = body.get("post_id")

            if not post_id:
                return response(400, {"message": "post_id required"})

            config_table.update_item(
                Key={"post_id": post_id},
                UpdateExpression="SET #s = :val",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":val": "CLOSED"}
            )

            return response(200, {"message": "Election closed"})

        # ====================================================
        # INVALID ACTION
        # ====================================================
        else:
            return response(400, {"message": "Invalid action"})

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, {"message": "Internal server error"})
