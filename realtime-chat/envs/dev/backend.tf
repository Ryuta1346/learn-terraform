

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "realtime-chat-terraform-state"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "us-east-1"
}




