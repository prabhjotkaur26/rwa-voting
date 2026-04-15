import json, boto3, os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['VOTE_TABLE'])

def lambda_handler(event, context):

    res = table.scan()
    items = res.get("Items", [])

    result = {}

    for i in items:
        post = i['post_id']
        cand = i['candidate_id']

        if post not in result:
            result[post] = {}

        result[post][cand] = result[post].get(cand, 0) + 1

    return {
        "statusCode": 200,
        "body": json.dumps(result)
    }
