terraform {
  backend "s3" {
    bucket         = "rwa-tf-state-backend-bucket"
    key            = "global/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "rwa-tf-lock"
    encrypt        = true
  }
}
