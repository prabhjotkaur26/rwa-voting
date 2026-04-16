import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')

voter_table = dynamodb.Table(os.environ['VOTER_TABLE'])
config_table = dynamodb.Table(os.environ['CONFIG_TABLE'])


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # SIMPLE ADMIN CHECK
        # -----------------------------
        headers = event.get("headers") or {}
        auth = headers.get("Authorization") or headers.get("authorization")

        if auth != "admin":
            return {
                "statusCode": 403,
                "body": json.dumps({"message": "Admin only"})
            }

        # -----------------------------
        # BODY PARSE
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        action = body.get("action")

        # ====================================================
        # 🟢 ACTION 1: ADD VOTERS
        # ====================================================
        if action == "add_voters":

            voters = body.get("voters", [])

            if not voters:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"message": "voters list required"})
                }

            for v in voters:
                email = v.get("email")

                if not email:
                    continue

                voter_table.put_item(
                    Item={
                        "email": email,
                        "is_verified": True
                    }
                )

            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Voters added successfully"})
            }

        # ====================================================
        # 🟢 ACTION 2: CREATE ELECTION
        # ====================================================
        elif action == "create_election":

            post_id = body.get("post_id")
            candidates = body.get("candidates", [])

            if not post_id or not candidates:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"message": "post_id and candidates required"})
                }

            if len(candidates) > 7:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"message": "Max 7 candidates allowed"})
                }

            config_table.put_item(
                Item={
                    "post_id": post_id,
                    "candidates": candidates,
                    "status": "CREATED"   # 👈 better than ACTIVE
                }
            )

            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Election created"})
            }

        # ====================================================
        # 🟢 ACTION 3: START ELECTION
        # ====================================================
        elif action == "start_election":

            post_id = body.get("post_id")

            if not post_id:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"message": "post_id required"})
                }

            config_table.update_item(
                Key={"post_id": post_id},
                UpdateExpression="SET #s = :val",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":val": "ACTIVE"}
            )

            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Election started"})
            }

        # ====================================================
        # 🟢 ACTION 4: CLOSE ELECTION
        # ====================================================
        elif action == "close_election":

            post_id = body.get("post_id")

            if not post_id:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"message": "post_id required"})
                }

            config_table.update_item(
                Key={"post_id": post_id},
                UpdateExpression="SET #s = :val",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":val": "CLOSED"}
            )

            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Election closed"})
            }

        # ====================================================
        # ❌ INVALID ACTION
        # ====================================================
        else:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Invalid action"})
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
