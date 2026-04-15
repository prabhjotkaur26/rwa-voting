import boto3, os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['VOTE_TABLE'])

def lambda_handler(event, context):
    table.put_item(
        Item=event,
        ConditionExpression="attribute_not_exists(voter_id)"
    )

    return {"status": "success"}
