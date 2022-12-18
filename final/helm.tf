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