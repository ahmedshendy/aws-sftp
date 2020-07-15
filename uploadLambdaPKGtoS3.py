import boto3
import os
from botocore.exceptions import ClientError
from zipfile import ZipFile
region = 'us-east-2'
bucket_name = '3ddx-lamdda-pkg'
s3_client = boto3.client('s3', region_name=region)
print("Create lambda repo bucket " + bucket_name + " in region " + region)
try:
    s3_client.create_bucket(Bucket=bucket_name,CreateBucketConfiguration={'LocationConstraint': region})
except ClientError as e:
    if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
        print("Bucket already exists")
    else:
        print("Unexpected error: %s" % e)

zip_name = "sftpFileHandler.zip"
dirname = '.\sftpFileHandler'
filename = 'index.py'
print("Create the lambda pkg " + zip_name)
with ZipFile(zip_name,'w') as zip: 
    zip.write(os.path.join(dirname, filename), arcname=filename)
s3_client.upload_file(
    Filename=zip_name, Bucket=bucket_name,
    Key=zip_name)
print("Lambda pkg " + zip_name + "has been uploaded")
    
zip_name = "sftpCustomAuthorizer.zip"
dirname = '.\sftpCustomAuthorizer'
filename = 'index.py'
print("Create the lambda pkg " + zip_name)
with ZipFile(zip_name,'w') as zip: 
    zip.write(os.path.join(dirname, filename), arcname=filename) 
s3_client.upload_file(
Filename=zip_name, Bucket=bucket_name,
Key=zip_name)
print("Lambda pkg " + zip_name + "has been uploaded")



