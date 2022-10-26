provider "aws" {
  region                  = var.region_name
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  region        = var.region_name
  acl           = "private"

  tags = {
    "Name" = format("%s", var.name)
  }
  
  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = format("%s-lock-db", var.name)
  read_capacity = 5
  write_capacity = 5
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}