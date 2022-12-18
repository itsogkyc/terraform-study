terraform {
  # TODO: state storage 정보 입력
  # key값은 버킷내에 tfstate 파일이 생성될 경로로써 다음 형태로 저장 :  <clustername>/vpc.tfstate
  backend "s3" {
    region                  = "us-west-2"
    bucket                  = "vpc-bucket"
    key                     = "cluster/vpc.tfstate"
    skip_metadata_api_check = true
  }
}

provider "aws" {
  region                  = "us-west-2"
  skip_metadata_api_check = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}