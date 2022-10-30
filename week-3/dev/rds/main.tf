terraform {
  backend "s3" {
    region                  = "ap-northeast-1"
    bucket                  = "kyc-terraform-backend-s3-test"
    key                     = "dev/rds.tfstate"
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

module "rds" {
    source = "../../modules/rds"
    name = local.cluster_name
    identifier_prefix = local.identifier_prefix
    engine = local.engine
    allocated_storage = local.allocated_storage
    instance_class = local.instance_class
    db_name = local.db_name
    db_username = local.username
    db_password = local.password
    # network
    subnet_ids = concat([data.terraform_remote_state.vpc.outputs.subnet4_id], [data.terraform_remote_state.vpc.outputs.subnet3_id])
    sg = [data.terraform_remote_state.vpc.outputs.sg_rds_id]
}
