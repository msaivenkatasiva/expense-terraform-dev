terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
  
    }
    
  }
  backend "s3" {
    bucket         = "msvs-remote-state"
    key            = "expense-project-dev-sg"
    region         = "us-east-1"
    dynamodb_table = "msvs-dynamo"
  }
}

provider "aws" {
    region = "us-east-1"
  # Configuration options
}

    