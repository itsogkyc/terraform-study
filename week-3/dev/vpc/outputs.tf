output "vpc_id" {
    value = module.vpc.vpc_id
}

output "subnet1_id" {
    value = module.vpc.subnet1_id
}

output "subnet2_id" {
    value = module.vpc.subnet2_id
}

output "subnet3_id" {
    value = module.vpc.subnet3_id
}

output "subnet4_id" {
    value = module.vpc.subnet4_id
}

output "sg_id" {
    value = module.vpc.sg  
}

output "sg_rds_id" {
    value = module.vpc.sg-rds  
}