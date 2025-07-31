import json
import boto3
import os

ses_client = boto3.client('ses', region_name=os.environ['AWS_REGION'])

def lambda_handler(event, context):
    sender = os.environ['SES_SENDER']
    recipient = os.environ['SES_RECIPIENT']
    
    # محتوى الإيميل
    subject = "Terraform State Change Notification"
    body_text = f"Terraform state changed.\n\nEvent details:\n{json.dumps(event, indent=2)}"
    
    try:
        response = ses_client.send_email(
            Source=sender,
            Destination={'ToAddresses': [recipient]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body_text}}
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Email sent successfully')
        }
    except Exception as e:
        print(f"Error sending email: {e}")
        raise e
