variable "name" {
    type = string
    default = "kyc-cluster"  
}

variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "sg" {
    type = list(string)
    default = []
}


variable "vpc_zone_identifier" {
    type = any
    default = []  
}

variable "max_size" {
    type = number
    default = 10
}

variable "min_size" {
    type = number
    default = 2
}

variable "subnet" {
    type = any
    default = []
}

variable "vpc_id" {
    type = string
    default = ""
}