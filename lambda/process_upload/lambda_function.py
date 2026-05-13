import json
import os
import boto3
import datetime

s3_client       = boto3.client('s3')
dynamodb_client = boto3.client('dynamodb')
sns_client      = boto3.client('sns')
   
def lambda_handler(event, context):
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key    = record['s3']['object']['key']

    timestamp = datetime.datetime.now().isoformat()

    dynamodb_client.put_item(
    TableName=os.environ.get('DYNAMODB_TABLE'),
    Item={
        'email':     {'S': key.split('_')[0]},
        'file_key':  {'S': key},
        'timestamp': {'S': timestamp}
        }
    )

    sns_client.publish(
    TopicArn=os.environ.get('SNS_TOPIC_ARN'),
    Subject='New Resume Submitted',
    Message=f'New resume uploaded!\nFile: {key}\nTime: {timestamp}'
    )

    return {
    'statusCode': 200,
    'headers': {
        'Access-Control-Allow-Origin': '*'
    },
    'body': json.dumps({
        'presigned_url': presigned_url,
        'file_name': file_name
    })
    }