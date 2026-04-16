import json, boto3, os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['VOTE_TABLE'])

def lambda_handler(event, context):

    items = []
    last_key = None

    # ✅ FULL SCAN (pagination fix)
    while True:
        if last_key:
            res = table.scan(ExclusiveStartKey=last_key)
        else:
            res = table.scan()

        items.extend(res.get("Items", []))
        last_key = res.get("LastEvaluatedKey")

        if not last_key:
            break

    result = {}

    for i in items:
        post = i.get('post_id')
        cand = i.get('candidate_id')

        if not post or not cand:
            continue  # skip bad data

        if post not in result:
            result[post] = {}

        result[post][cand] = result[post].get(cand, 0) + 1

    return {
        "statusCode": 200,
        "body": json.dumps(result)
    }
