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