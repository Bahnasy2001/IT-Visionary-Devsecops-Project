import json
import boto3
import os

ses_client = boto3.client('ses')  # هيقرأ الريجن تلقائي من بيئة التنفيذ

def lambda_handler(event, context):
    sender = os.environ['SES_SENDER']
    recipient = os.environ['SES_RECIPIENT']
    
    # نجيب نوع الحدث وبعض البيانات من الحدث نفسه
    event_type = event.get('detail-type', 'Unknown Event')
    account = event.get('account', 'Unknown Account')
    region = event.get('region', 'Unknown Region')
    time = event.get('time', 'Unknown Time')

    # موضوع الإيميل
    subject = f"Terraform Notification: {event_type}"
    
    # محتوى الإيميل بشكل مرتب
    body_text = f"""
Hello,

This is an automated notification from Terraform.

Event Type: {event_type}
AWS Account: {account}
Region: {region}
Time: {time}

Full event data:
{json.dumps(event, indent=2)}

Regards,
Terraform Automation
"""

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
