import json, boto3, os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['VOTES_TABLE'])

def lambda_handler(event, context):
    electionId = event['pathParameters']['electionId']
    postId = event['pathParameters']['postId']

    pk = f"{electionId}#{postId}"

    res = table.query(
        KeyConditionExpression="PK = :pk",
        ExpressionAttributeValues={":pk": pk}
    )

    result = {}

    for item in res['Items']:
        cid = item['candidateId']
        result[cid] = result.get(cid, 0) + 1

    return {
        "statusCode": 200,
        "body": json.dumps(result)
    }
