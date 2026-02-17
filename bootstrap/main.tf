provider "aws" {
  region = "us-east-1"
}

# 1. S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "devsecops-sanitryapp-state-${random_id.suffix.hex}" # Must be globally unique
  
  lifecycle {
    prevent_destroy = false # Security best practice: don't accidentally delete your state
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. DynamoDB for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST" # Free Tier friendly
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}
