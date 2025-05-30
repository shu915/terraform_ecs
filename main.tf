terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40.0"
    }
  }
}
provider "aws" {
  region  = "ap-northeast-1"
  profile = "terraform"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "secret_manager_arn" {
  type = string
}

variable "db_host" {
  type = string
}
