#!/bin/bash
set -e

echo "Initializing AWS Infrastructure Bootstrap..."

terraform init
terraform plan
sleep 5
echo 
terraform apply -auto-approve

# Extract the bucket name for the next step
BUCKET_NAME=$(terraform output -raw state_bucket_name)

echo "Resources created. Bucket: $BUCKET_NAME"
echo "Now, copy this bucket name into your root backend.tf file."
