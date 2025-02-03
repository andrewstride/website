terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
  profile = var.AWS_PROFILE
  assume_role {
    role_arn = "arn:aws:iam::650251716475:user/website-terraform"
  }
}

terraform {
  backend "s3" {
    bucket = "andrewstride-website-tf-state"
    key    = "website.tfstate"
    region = "eu-west-2"
  }
}

