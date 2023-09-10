terraform {

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
  }
  required_version = ">= 1.5.5"
}

provider "aws" {
  default_tags {
    tags = {
      Environment = "sandbox"
    }
  }
}
