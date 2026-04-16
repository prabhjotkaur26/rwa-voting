import json
import boto3
import os
import jwt
import csv
from io import StringIO, BytesIO
from datetime import datetime
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
            return {"statusCode": 401, "body": "Missing token"}

        token = auth_header.replace("Bearer ", "").strip()

        decoded = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])

        if not decoded.get("isAdmin"):
            return {"statusCode": 403, "body": "Admin only"}

        # -----------------------------
        # BODY
        # -----------------------------
        body = event.get("body") or "{}"

        if isinstance(body, str):
            body = json.loads(body)

        post_id = body.get("post_id")

        if not post_id:
            return {"statusCode": 400, "body": "post_id required"}

        # -----------------------------
        # FETCH VOTES
        # -----------------------------
        response = vote_table.scan(
            FilterExpression="post_id = :p",
            ExpressionAttributeValues={":p": post_id}
        )

        votes = response.get("Items", [])

        if not votes:
            return {"statusCode": 404, "body": "No votes found"}

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

        csv_key = f"exports/{post_id}_{datetime.utcnow().timestamp()}.csv"

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

        pdf_key = f"exports/{post_id}_{datetime.utcnow().timestamp()}.pdf"

        s3.put_object(
            Bucket=BUCKET,
            Key=pdf_key,
            Body=pdf_buffer.getvalue()
        )

        # -----------------------------
        # RETURN LINKS
        # -----------------------------
        csv_url = f"https://{BUCKET}.s3.amazonaws.com/{csv_key}"
        pdf_url = f"https://{BUCKET}.s3.amazonaws.com/{pdf_key}"

        return {
            "statusCode": 200,
            "body": json.dumps({
                "csv": csv_url,
                "pdf": pdf_url
            })
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Internal error", "error": str(e)})
        }
