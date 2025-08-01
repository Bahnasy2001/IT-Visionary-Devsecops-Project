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
          "ses:SendRawEmail"
        ],
        Resource = "arn:aws:ses:us-east-1:911167904183:identity/ahmedrafat530@gmail.com"      }
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
  tracing_config {
  mode = "Active"
  }
 
  source_code_hash = filebase64sha256(var.lambda_zip_file)

  environment {
    variables = {
      SES_SENDER    = var.ses_sender_email
      SES_RECIPIENT = var.ses_recipient_email
      
    }
  }
}
