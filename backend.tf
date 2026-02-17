terraform {
  backend "s3" {
    bucket       = "devsecops-sanitryapp-state-cae66e45"
    key          = "dev/dotnet-app.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Replaces dynamodb_table
  }
}
