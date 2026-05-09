terraform {
  backend "s3" {
    bucket         = "amit-resume-tf-state-2025"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "resume-platform-tf-lock"
    encrypt        = true
  }
}