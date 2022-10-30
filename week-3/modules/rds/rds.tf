resource "aws_db_subnet_group" "mydbsubnet" {
  name       = "mydbsubnetgroup"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}


resource "aws_db_instance" "myrds" {
  identifier_prefix      = var.identifier_prefix
  engine                 = var.engine
  allocated_storage      = var.allocated_storage
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.mydbsubnet.name
  vpc_security_group_ids = var.sg
  skip_final_snapshot    = true

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
}