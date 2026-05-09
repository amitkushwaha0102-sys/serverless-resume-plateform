provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "tf_state"{
 bucket = "amit-resume-tf-state-2025"
}

resource "aws_s3_bucket_versioning" "tf_state_version" {
 bucket = aws_s3_bucket.tf_state.id
 versioning_configuration{
 status = "Enabled"
 }
}
resource "aws_dynamodb_table" "tf_state_dynamodb"{
    name ="resume-platform-tf-lock" 
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute{
        name = "LockID"
        type = "S"
    }
}