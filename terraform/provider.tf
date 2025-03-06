terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.AWS_REGION
  profile = var.AWS_PROFILE
}

terraform {
  backend "s3" {
    bucket = "andrewstride-website-tf-state"
    key    = "website.tfstate"
    region = "eu-west-2"
  }
}

