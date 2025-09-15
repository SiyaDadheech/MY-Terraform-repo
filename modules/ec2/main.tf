resource "aws_instance"  "public" {
  ami  = var.ec2_config.ami
  instance_type = var.ec2_config.instance_type
  subnet_id = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = var.security_group_ids
  key_name = "MyAwsKey"

  tags = {
    Name = "public-ec2"
  }
}

resource "aws_instance" "private" {
  ami = var.ec2_config.ami
  instance_type = var.ec2_config.instance_type
  subnet_id = var.private_subnet_id
  key_name = "MyAwsKey"

  vpc_security_group_ids = var.security_group_ids
  tags = {
     Name = "private-ec2"
  }
}

variable "security_group_ids" {
  description = "security group"
  type = list(string)
}
