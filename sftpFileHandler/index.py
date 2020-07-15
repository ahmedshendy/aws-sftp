import json
import urllib.parse
import boto3
import zipfile
from io import BytesIO

print('Loading function')

s3 = boto3.resource('s3')
s3_client = boto3.client('s3')
targetBucket = os.environ['TargetBucket']


def lambda_handler(event, context):
    # print("Received event: " + json.dumps(event, indent=2))
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    print('Reciving new file: ' + key)
    copy_source = {
      'Bucket': bucket,
      'Key': key
    }
    if 'zip' not in key:
        return key
    try:
        zip_obj = s3.Object(bucket, key)
        buffer = BytesIO(zip_obj.get()["Body"].read())
        metadata = {}
        z = zipfile.ZipFile(buffer)
        for filename in z.namelist():
            if 'OrderForm' in filename:
                data = z.open(filename, 'r')
                Lines = data.readlines()
                for line in Lines: 
                    if '//' not in str(line.strip()):
                        # print(str(line.strip()))
                        item = str(line.strip()).replace("b'","")[:-1].split('=')
                        metadata[item[0]] = item[1]
        s3_client.copy_object(Key=key, Bucket=targetBucket,
               CopySource=copy_source,
               Metadata=metadata,
               MetadataDirective="REPLACE")
        print('Metadata has been updated for file: ' + key)
        return key
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        print('Error in handling file: ' + key)
        raise e
