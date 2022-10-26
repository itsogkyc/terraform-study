terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region                  = local.region_name
}

module "backend_init" {
  source = "../../modules/init"
  name = local.name
  region_name = local.region_name
  bucket_name = local.bucket_name
}

