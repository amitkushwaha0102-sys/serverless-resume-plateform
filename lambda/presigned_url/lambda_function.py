import json
import os
import boto3

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = os.environ.get('UPLOAD_BUCKET')
    if not bucket_name:
        raise ValueError("Missing required environment variable UPLOAD_BUCKET")

    file_name = event.get('file_name')
    email = event.get('email')
    job_role = event.get('job_role')

    presigned_url = s3_client.generate_presigned_url(
        'put_object',
        Params={
            'Bucket': bucket_name,
            'Key': file_name,
            'ContentType': 'application/pdf'
        },
        ExpiresIn=300
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