import json
import boto3
import os
import jwt
import csv
from io import StringIO, BytesIO
from datetime import datetime
from botocore.exceptions import ClientError
from reportlab.platypus import SimpleDocTemplate, Paragraph
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

vote_table = dynamodb.Table(os.environ['VOTE_TABLE'])
config_table = dynamodb.Table(os.environ['CONFIG_TABLE'])

BUCKET = os.environ['BUCKET']
JWT_SECRET = os.environ['JWT_SECRET']


def lambda_handler(event, context):
    try:
        print("EVENT:", event)

        # -----------------------------
        # AUTH (ADMIN ONLY)
        # -----------------------------
        headers = event.get("headers") or {}
        auth_header = headers.get("Authorization") or headers.get("authorization")

        if not auth_header:
            return response(401, "Missing token")

        token = auth_header.replace("Bearer ", "").strip()

        try:
            decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        except Exception as e:
            return response(401, f"Invalid token: {str(e)}")

        if not decoded.get("isAdmin"):
            return response(403, "Admin only")

        # -----------------------------
        # BODY PARSE
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("post_id")

        if not post_id:
            return response(400, "post_id required")

        # -----------------------------
        # CHECK ELECTION STATUS
        # -----------------------------
        config = config_table.get_item(Key={"post_id": post_id})
        item = config.get("Item", {})

        if item.get("status") != "CLOSED":
            return response(400, "Election not closed yet")

        # -----------------------------
        # FETCH ALL VOTES (PAGINATION SAFE)
        # -----------------------------
        votes = []
        response_db = vote_table.scan(
            FilterExpression="post_id = :p",
            ExpressionAttributeValues={":p": post_id}
        )

        votes.extend(response_db.get("Items", []))

        while "LastEvaluatedKey" in response_db:
            response_db = vote_table.scan(
                FilterExpression="post_id = :p",
                ExpressionAttributeValues={":p": post_id},
                ExclusiveStartKey=response_db["LastEvaluatedKey"]
            )
            votes.extend(response_db.get("Items", []))

        if not votes:
            return response(404, "No votes found")

        # -----------------------------
        # COUNT RESULTS
        # -----------------------------
        result = {}

        for v in votes:
            cid = v["candidate_id"]
            result[cid] = result.get(cid, 0) + 1

        # -----------------------------
        # CSV GENERATION
        # -----------------------------
        csv_buffer = StringIO()
        writer = csv.writer(csv_buffer)

        writer.writerow(["Candidate ID", "Votes"])

        for cid, count in result.items():
            writer.writerow([cid, count])

        csv_key = f"exports/{post_id}_{int(datetime.utcnow().timestamp())}.csv"

        s3.put_object(
            Bucket=BUCKET,
            Key=csv_key,
            Body=csv_buffer.getvalue()
        )

        # -----------------------------
        # PDF GENERATION
        # -----------------------------
        pdf_buffer = BytesIO()

        doc = SimpleDocTemplate(pdf_buffer, pagesize=letter)
        styles = getSampleStyleSheet()

        elements = []
        elements.append(Paragraph(f"Election Results (Post {post_id})", styles['Title']))

        for cid, count in result.items():
            elements.append(Paragraph(f"{cid}: {count} votes", styles['Normal']))

        doc.build(elements)

        pdf_buffer.seek(0)

        pdf_key = f"exports/{post_id}_{int(datetime.utcnow().timestamp())}.pdf"

        s3.put_object(
            Bucket=BUCKET,
            Key=pdf_key,
            Body=pdf_buffer.getvalue()
        )

        # -----------------------------
        # GENERATE PRESIGNED URL (IMPORTANT FIX)
        # -----------------------------
        csv_url = s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': BUCKET, 'Key': csv_key},
            ExpiresIn=3600
        )

        pdf_url = s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': BUCKET, 'Key': pdf_key},
            ExpiresIn=3600
        )

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "csv": csv_url,
                "pdf": pdf_url
            })
        }

    except Exception as e:
        print("ERROR:", str(e))
        return response(500, str(e))


# -----------------------------
# COMMON RESPONSE FUNCTION
# -----------------------------
def response(code, message):
    return {
        "statusCode": code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": message})
    }
