variable "name" {
  type = list(string)
  default = ["a", "b", "c"]
}

output "upper_name" {
  value = [for name in var.name : upper(name)]
}
