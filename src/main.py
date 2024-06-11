import json
import boto3
from PIL import Image
import io


def lambda_handler(event, context):
    s3 = boto3.client('s3')
    images = []
    
    for record in event["Records"]:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']
        
        response = s3.get_object(Bucket=bucket_name, Key=object_key)
        object_data = response['Body'].read()

        # Generate a thumbnail
        image = Image.open(io.BytesIO(object_data))
        thumbnail_size = (128, 128)
        image.thumbnail(thumbnail_size)
        thumbnail_data = io.BytesIO()
        image.save(thumbnail_data, format='JPEG')

        # Upload the thumbnail to S3
        thumbnail_key = f'thumbnails/{object_key}_thumbnail.jpg'
        s3.put_object(Body=thumbnail_data.getvalue(), Bucket=bucket_name, Key=thumbnail_key)
        images.append(f'thumbnails/{object_key}_thumbnail.jpg')

        
    return {
        'statusCode': 200,
        'body': json.dumps(images)
    }
