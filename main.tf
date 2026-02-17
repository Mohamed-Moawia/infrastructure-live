# 1. IAM Role for App Runner to access GHCR/ECR (Access Role)
resource "aws_iam_role" "app_runner_access_role" {
  name = "app-runner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "build.apprunner.amazonaws.com" }
    }]
  })
}

# 2. IAM Role for the Application Runtime (Instance Role)
# This is where you'd add permissions for the .NET app to talk to S3/DynamoDB later
resource "aws_iam_role" "app_runner_instance_role" {
  name = "app-runner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
    }]
  })
}

# 3. App Runner Service Definition
resource "aws_apprunner_service" "dotnet_app" {
  service_name = "dotnet10-sec-app"

  source_configuration {
    # We start with a public placeholder image because your code isn't built yet.
    # Your CI/CD will later update this to your private GHCR image.
    image_repository {
      image_identifier      = "public.ecr.aws/aws-containers/hello-app-runner:latest"
      image_repository_type = "ECR_PUBLIC"

      image_configuration {
        port = "8080" # Standard .NET Default
        runtime_environment_variables = {
          "ASPNETCORE_ENVIRONMENT" = "Development"
        }
      }
    }
    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = "0.25 vCPU" # Lowest possible for Free Tier savings
    memory            = "0.5 GB"
    instance_role_arn = aws_iam_role.app_runner_instance_role.arn
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Output the URL so you know where to view your app
output "app_url" {
  value = "https://${aws_apprunner_service.dotnet_app.service_url}"
}
