variable "bucket_Name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Name        = "s3backend"
    Environment = "Prod"
  }
}
