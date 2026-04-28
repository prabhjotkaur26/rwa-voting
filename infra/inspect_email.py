import boto3

print('--- DynamoDB voter-registry scan ---')
dyn = boto3.resource('dynamodb', region_name='ap-south-1')
try:
    table = dyn.Table('voter-registry')
    resp = table.scan(Limit=100)
    print('Count:', resp.get('Count'))
    for item in resp.get('Items', []):
        print(item)
except Exception as e:
    print('DynamoDB error:', e)

print('\n--- SES verified email identities ---')
ses = boto3.client('ses', region_name='ap-south-1')
try:
    ids = ses.list_identities(IdentityType='EmailAddress', MaxItems=50)
    print('Identity count:', len(ids.get('Identities', [])))
    for identity in ids.get('Identities', []):
        attrs = ses.get_identity_verification_attributes(Identities=[identity])['VerificationAttributes'].get(identity, {})
        print(identity, attrs)
except Exception as e:
    print('SES error:', e)
