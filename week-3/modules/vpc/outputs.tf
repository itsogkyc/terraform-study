output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "subnet1_id" {
    value = aws_subnet.subnet1.id
}

output "subnet2_id" {
    value = aws_subnet.subnet2.id
}

output "subnet3_id" {
    value = aws_subnet.subnet3.id
}

output "subnet4_id" {
    value = aws_subnet.subnet4.id
}

output "sg" {
    value = aws_security_group.sg.id 
}

output "sg-rds" {
    value = aws_security_group.sg-rds.id 
}