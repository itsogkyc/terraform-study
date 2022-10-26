variable "name" {
    description = "name of backend"
    type = string
}

variable "region_name" {
  description = "target region"
  type        = string
}

variable "bucket_name" {
  description = "save for tfstate file"
  type        = string
}