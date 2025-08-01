resource "aws_iam_role" "lambda_role" {
  name = "lambda_ses_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_ses_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "sns:Publish"
        ],
        Resource = [
          "arn:aws:ses:us-east-1:911167904183:identity/ahmedrafat530@gmail.com",
          aws_sns_topic.terraform_notifications.arn
        ]
      }
    ]
  })
}

#Checkov skip comments must be placed directly above the resource

resource "aws_lambda_function" "notify" {
# checkov:skip=CKV_AWS_117:Lambda doesn't need VPC for SES email notifications
# checkov:skip=CKV_AWS_272:Code signing not required for internal automation
# checkov:skip=CKV_AWS_173:Environment variables don't contain sensitive data
# checkov:skip=CKV_AWS_116:DLQ not required for simple email notifications
# checkov:skip=CKV_AWS_115:DLQ not required for simple email notifications

  filename         = var.lambda_zip_file
  function_name    = "notify_on_state_change"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
   timeout = 60
  tracing_config {
  mode = "Active"
  }
  
  source_code_hash = filebase64sha256(var.lambda_zip_file)

  environment {
    variables = {
      SES_SENDER    = var.ses_sender_email
      SES_RECIPIENT = var.ses_recipient_email
      SNS_TOPIC_ARN = aws_sns_topic.terraform_notifications.arn

      
    }
  }
}
resource "aws_cloudwatch_event_rule" "terraform_apply_rule" {
  name        = "terraform-apply-complete"
  description = "Trigger Lambda after Terraform apply"
  event_pattern = <<PATTERN
{
  "source": ["custom.terraform"],
  "detail-type": ["Terraform Apply"]
}
PATTERN
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.terraform_apply_rule.arn
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.terraform_apply_rule.name
  target_id = "NotifyLambda"
  arn       = aws_lambda_function.notify.arn
}

resource "aws_sns_topic" "terraform_notifications" {
  # checkov:skip=CKV_AWS_26:Environment variables don't contain sensitive data

  name = "terraform-notifications-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.terraform_notifications.arn
  protocol  = "email"
  endpoint  = var.ses_recipient_email
}
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.notify.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.terraform_notifications.arn
    }
    on_success {
      destination = aws_sns_topic.terraform_notifications.arn    
    # ممكن تضيف on_success برضه لو عايز
  }
}
