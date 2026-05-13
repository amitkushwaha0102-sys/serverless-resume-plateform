provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.project}-upload_bucket"
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