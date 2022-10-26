terraform {
  backend "s3" {
    region                  = "ap-northeast-1"
    bucket                  = "kyc-terraform-backend-s3-test"
    key                     = "dev/asg-alb.tfstate"
  }
}

provider "aws" {
  region                  = local.region
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region                  = "ap-northeast-1"
    bucket                  = "kyc-terraform-backend-s3-test"
    key                     = "dev/vpc.tfstate"
    skip_metadata_api_check = true
  }
}

module "asg_alb" {
    source = "../../modules/asg-alb"
    name = local.name
    instance_type = local.instance_type
    max_size = local.max_size
    min_size = local.min_size
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    vpc_zone_identifier = concat([data.terraform_remote_state.vpc.outputs.subnet2_id], [data.terraform_remote_state.vpc.outputs.subnet1_id])
    subnet = concat([data.terraform_remote_state.vpc.outputs.subnet2_id], [data.terraform_remote_state.vpc.outputs.subnet1_id])
    sg = [data.terraform_remote_state.vpc.outputs.sg_id]
}
