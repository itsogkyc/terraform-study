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

# remote state vpc
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region                  = "ap-northeast-1"
    bucket                  = "kyc-terraform-backend-s3-test"
    key                     = "dev/vpc.tfstate"
    skip_metadata_api_check = true
  }
}

# remote state rds
data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    region = "ap-northeast-1"
    bucket = "kyc-terraform-backend-s3-test"
    key    = "dev/rds.tfstate"
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

    # rds info
    server_port = local.server_port
    db_address = data.terraform_remote_state.rds.outputs.address
    db_port = data.terraform_remote_state.rds.outputs.port
}
