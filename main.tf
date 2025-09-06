resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = local.project
  }
  
}
locals {
  project = "project01"
}
#creating subnet
resource "aws_subnet" "main" {
  vpc_id      = aws_vpc.my-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  count       = 2
  tags = {
    Name = "${local.project}-subnet-${count.index}"

  }
  availability_zone = "ap-south-1b"
}
#create ec2 instance
resource "aws_instance" "main" {
  ami           = var.ec2_config[count.index].ami
  instance_type = var.ec2_config[count.index].instance_type
  subnet_id     = element(aws_subnet.main[*].id, count.index % length(aws_subnet.main))
  count         = length(var.ec2_config) //making it dynamic
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${local.project}-instance-${count.index}"
  }
}
