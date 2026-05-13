provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.project}-upload-bucket"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.project}-frontend"
}

resource "aws_sns_topic" "hr_notification"{
  name  = "${var.project}-hr-notifications"
}

resource "aws_dynamodb_table" "submission"{
    name ="${var.project}-submissions"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "email"
    attribute{
        name = "email"
        type = "S"
    }
}

resource "aws_iam_role" "lambda_role" {
    name = "${var.project}-lambda_role"
    assume_role_policy =  jsonencode({
         Version = "2012-10-17"
         Statement = [{
         Effect    = "Allow"
         Principal = { Service = "lambda.amazonaws.com" }
         Action    = "sts:AssumeRole"
  }]
 })
}

resource "aws_iam_role_policy" "lambda_policy" {
    name = "${var.project}-lambda_policy"
    role = aws_iam_role.lambda_role.id
    policy = jsonencode({
    Version = "2012-10-17"
   Statement = [
  {
    Effect   = "Allow"
    Action   = ["s3:PutObject", "s3:GetObject"]
    Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
  },
  {
    Effect   = "Allow"
    Action   = ["dynamodb:PutItem"]
    Resource = aws_dynamodb_table.submission.arn
  },
  {
    Effect   = "Allow"
    Action   = ["sns:Publish"]
    Resource = aws_sns_topic.hr_notification.arn
  },
  {
    Effect   = "Allow"
    Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    Resource = "arn:aws:logs:*:*:*"
  }
]
})
}
resource "aws_apigatewayv2_api" "resume_api" {
  name          = "${var.project}-api"
  protocol_type = "HTTP"
    cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.resume_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.presigned_url.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_url_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "POST /get-url"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.resume_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_function" "presigned_url" {
  filename         = "../lambda/presigned_url/lambda.zip"
  function_name    = "${var.project}-presigned-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"

  environment {
    variables = {
      UPLOAD_BUCKET = aws_s3_bucket.upload_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "process_upload" {
  filename         = "../lambda/process_upload/lambda.zip"
  function_name    = "${var.project}-process-upload"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.submission.name
      SNS_TOPIC_ARN  = aws_sns_topic.hr_notification.arn
    }
  }
}