terraform {
  # Minimum Terraform version
  required_version = ">= 1.5.0"

  # Define required provider plugins
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
 }
  backend "s3" {
    bucket         = "tfstate-dev-us-east-1-17"         
    key            = "retail-persistent-endpoints/dev/terraform.tfstate"            
    region         = "us-east-1"                            
    encrypt        = true                                   
    use_lockfile   = true     
  }
}

provider "aws" {
  # AWS region to use for all resources (from variables)
  region = var.aws_region
}


provider "aws" {
  alias  = "west2"
  region = "us-west-2"
}


