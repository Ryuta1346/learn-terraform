terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "learn-terraform-admin-state"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "ap-northeast-1"
}



