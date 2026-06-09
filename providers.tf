terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "meu-estado-terraform-brito-1998"
    key    = "from-junior-to-senior/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.regiao_aws
}