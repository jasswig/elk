terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.45.0"
    }
    elasticstack = {
      source = "elastic/elasticstack"
      version = "0.5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
  shared_config_files = ["/Users/Jaskaran.Singh/.aws/credentials"]
  profile = "hello-world"
}


