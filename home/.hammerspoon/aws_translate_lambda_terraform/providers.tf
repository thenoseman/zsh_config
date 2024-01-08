terraform {

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.1"
    }
  }
  required_version = ">= 1.5.5"
}

provider "aws" {
  default_tags {
    tags = {
      Environment = "sandbox"
      Project     = "aws-translate"
    }
  }
}
