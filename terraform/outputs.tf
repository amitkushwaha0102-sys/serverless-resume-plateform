output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend_bucket.bucket
}

output "upload_bucket_name" {
  value = aws_s3_bucket.upload_bucket.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.hr_notification.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.submission.name
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}