terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}

module "frontend" {
  source          = "./cloud-resume-frontend"
  website_aliases = ["resume.patimapoochai.net", "www.patimapoochai.net"]
}
