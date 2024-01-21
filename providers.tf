terraform {
  required_version = ">=1.0"

  backend "s3" {
    bucket = "terraform-state-rhhtdrmclbni"
    key    = "terraform.tfstate"
    region = var.aws_bucket_location
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
  aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_bucket_location
}