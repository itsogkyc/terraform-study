variable "cluster_name" {
  type        = string
  description = "name of this cluster"
  default     = "kyc-cluster"
}

variable "vpc_cidr" {
  type        = string
  description = "cidr of vpc"
  default     = "10.10.0.0/16"
}

variable "enable_dns_hostnames" {
  type        = string
  description = "enable dns hostname"
  default     = "true"
}

variable "enable_dns_support" {
  type        = string
  description = "enable dns hostname"
  default     = "true"
}

variable "subnet_az1" {
  type    = string
  default = "ap-northeast-1a"
}

variable "subnet_az2" {
  type    = string
  default = "ap-northeast-1c"
}

variable "subnet_az3" {
  type    = string
  default = "ap-northeast-1a"
}

variable "subnet_az4" {
  type    = string
  default = "ap-northeast-1c"
}

variable "subnet1" {
  type    = string
  default = "10.10.1.0/24"
}

variable "subnet2" {
  type    = string
  default = "10.10.2.0/24"
}

variable "subnet3" {
  type    = string
  default = "10.10.3.0/24"
}

variable "subnet4" {
  type    = string
  default = "10.10.4.0/24"
}