terraform {
  backend "s3" {
    region                  = "ap-northeast-1"
    bucket                  = "kyc-terraform-backend-s3-test"
    key                     = "dev/vpc.tfstate"
  }
}

provider "aws" {
  region                  = local.region
}

module "vpc" {
    source = "../../modules/vpc"
    cluster_name = local.cluster_name
    vpc_cidr = local.vpc_cidr
    subnet1 = local.subnet1
    subnet2 = local.subnet2
    subnet_az1 = local.subnet_az1
    subnet_az2 = local.subnet_az2
    # private for rds
    subnet3 = local.subnet3
    subnet4 = local.subnet4
    subnet_az3 = local.subnet_az4
    subnet_az4 = local.subnet_az3    
}