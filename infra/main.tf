terraform {
  backend "s3" {
    bucket         = "rwa-terraform-state-123"
    key            = "state/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
