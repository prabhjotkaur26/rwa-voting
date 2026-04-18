########################################
# AWS REGION
########################################
variable "region" {
  description = "AWS region where all resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

########################################
# PROJECT NAME
########################################
variable "project_name" {
  description = "Base name used for naming AWS resources"
  type        = string
  default     = "rwa-voting"
}
