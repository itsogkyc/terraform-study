# AWS with Terraform

> CloudNet 에서 가시다님의 주도하에 진행했던 테라폼 스터디의 마지막 과제를 작성해 보려고 합니다. 이야기할 주제는 최근 회사에서 많이 사용하고 있는 EKS로 선정했습니다. 테라폼 코드로 EKS를 배포하고, 클러스터에 기본으로 필요한 패키지를 helm provider 를 사용해 테라폼 코드로 관리할 수 있도록 구성해보겠습니다. 

- 테라폼을 사용한 EKS는 각각의 테라폼 리소스를 하나부터 직접 코딩하여 만들수도 있지만, 테라폼에서 제공하는 EKS 모듈을 이용하면 보다 쉽게 생성이 가능합니다.
- EKS 를 배포하는 순서는 다음과 같습니다. `VPC생성` - `EKS생성` - `helm차트 배포`

## 1. VPC 와 Subnet 생성
EKS를 생성할 때 사용할 VPC 생성이 선행되어야 합니다. 아래 테라폼 코드를 작성하여 [VPC](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/configure-your-vpc.html) ,[subnet](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/configure-subnets.html) 을 생성합니다.

- `vpc.tf`

```
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
```

## 2. VPC 와 Subnet 생성
