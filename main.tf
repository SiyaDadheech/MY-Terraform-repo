#vpc

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = local.project
  }
}

# locals

locals {
  project = "project01"
}

#assign availability zones accordingly

data "aws_availability_zones" "az" {
  state = "available"
}

#creating subnets


resource "aws_subnet" "main" {
  vpc_id = aws_vpc.my_vpc.id
  count  = length(var.ec2_config)
  cidr_block = "10.0.${count.index+1}.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "${local.project}-subnet-${count.index}"
  }
}

#creating route table


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "${local.project}-rt"
}
}

#internet gateway


resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
     Name = "${local.project}-ig"
  }

}

#route table association


resource "aws_route_table_association" "rt-associate" {
  count = length(aws_subnet.main)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.rt.id
}
#creating security group


resource "aws_security_group" "ec2-sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "Allow HTTP for NGINX"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["Your-instance-ip/32"] //or ["0.0.0.0/32"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}


#creating  ec2 instance


resource "aws_instance" "ec2" {
  ami               = var.ec2_config[count.index].ami
  instance_type     = var.ec2_config[count.index].instance_type
  subnet_id         = element(aws_subnet.main[*].id, count.index % length(aws_subnet.main))
  count             = length(var.ec2_config)
  key_name = "MyAwsKey"
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "${local.project}-instance-${count.index}"

  }
}

#output

output "public_ip_of_ec2" {
  description = "Public IPs of ec2 instance"
  value = [for instance in aws_instance.ec2 : instance.public_ip]
}
