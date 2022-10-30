locals {
  cluster_name = "kyc-cluster"
  region = "ap-northeast-1"
  identifier_prefix = "kyc"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  # rds info
  db_name = "kycrds"
  username = "kyc"
  password = "kycrds123!"
}