terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.40.0"
    }
  }
}
provider "aws" {
  region = "ap-northeast-1"
  profile = "terraform"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}