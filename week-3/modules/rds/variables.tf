variable "name" {
    type = string
    default = "kyc-cluster"
}

variable "subnet_ids" {
    type = list(string)
    default = []
}

variable "vpc_id" {
    type = string
    default = ""
}

variable "identifier_prefix" {
    type = string
    default = "kyc"  
}

variable "engine" {
    type = string
    default = "mysql"      
}

variable "allocated_storage" {
    type = number
    default = 10
}

variable "instance_class" {
    type = string
    default = "db.t2.micro"      
}

variable "sg" {
    type = list(string)
    default = []
}

## db configure
variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "tstudydb"
}