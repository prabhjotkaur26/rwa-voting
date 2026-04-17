variable "region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "rwa-voting"
}
variable "voter_emails" {
  type = list(string)

  default = [
    "prabh008968@gmail.com",
    "kaurprabhsidhu852004@gmail.com",
    "prabhjot582004@gmail.com
  ]
}
