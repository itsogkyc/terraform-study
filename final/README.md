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

## 2. EKS 생성
[EKS](https://aws.amazon.com/ko/eks/) 모듈을 사용하여 AWS에 쿠버네티스 클러스터를 생성합니다. 

- `eks.tf`

```
terraform {
  # TODO: state storage 정보 입력
  # key값은 버킷내에 tfstate 파일이 생성될 경로로써 다음 형태로 저장 :  <clustername>/eks.tfstate
  backend "s3" {
    region                  = "us-west-2"
    bucket                  = "eks-bucket"
    key                     = "cluster/eks.tfstate"
    skip_metadata_api_check = true
  }
}

provider "aws" {
  region                  = "us-west-2"
  skip_metadata_api_check = true
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # 아래에 1번에서 생성한 vpc,subnet 정보를 입력합니다.
  vpc_id                   = "<Enter your VPC ID>"
  subnet_ids               = ["subnet-01", "subnet-02", "subnet-03"]
  control_plane_subnet_ids = ["subnet-04", "subnet-05", "subnet-06"]

  # 워커노드의 타입은 크게 managed, self managed, fargate 로 구성할 수 있습니다.
  # 아래는 Self Managed Node Group(s) 예시로 생성할 노드그룹의 사양을 입력합니다. 
  self_managed_node_group_defaults = {
    instance_type                          = "m6i.large"
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 5
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "m5.large"
            weighted_capacity = "1"
          },
          {
            instance_type     = "m6i.large"
            weighted_capacity = "2"
          },
        ]
      }
    }
  }

  # EKS Managed Node Group 을 추가합니다. 
  # 인스턴스 타입, 인스턴스 수량, 타입을 지정할 수있습니다. 
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  # 파게이트를 이용한 클러스터를 구성하고 싶을 경우 입력
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  # aws-auth configmap 에 사용자를 등록하여 클러스터 제어 대상을 제한할 수 있습니다.
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::<account ID>:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::<account ID>:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::<account ID>:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "<account ID>",
    "<account ID>",
  ]

  # eks 에 추가할 태그정보를 입력합니다. 
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## 3. helm provider를 사용해 차트 배포하기
테라폼에서 제공하는 [helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) 를 사용해 생성한 EKS에 배포할 차트를 입력합니다. 

- `helm.tf`

```
# eks 클러스터명을 입력합니다.
data "aws_eks_cluster" "test" {
  name = "my-cluster"
}

data "aws_eks_cluster_auth" "test" {
  name = "my-cluster"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.test.endpoint
    token                  = data.aws_eks_cluster_auth.test.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.test.certificate_authority[0].data)
  }
}

# 설치하고자 하는 패키지 정보 및 레포지토리 경로를 입력합니다. 
resource "helm_release" "metrics_server" {
  namespace        = "kube-system"
  name             = "metrics-server"
  chart            = "metrics-server"
  version          = "3.8.2"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  create_namespace = true
  
  set {
    name  = "replicas"
    value = 2
  }
}
```


지금까지 테라폼 코드로 vpc, eks, helm chart 를 배포하는 과정을 알아보았습니다. 테라폼 코드를 사용하면 코드로 생성한 내역을 관리할 수 있고, 재활용할 수 있으며 협업에 용이한 툴이라는 것을 이번 학습을 통해 느낄수 있었다. 