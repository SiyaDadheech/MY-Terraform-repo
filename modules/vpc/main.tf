resource "aws_vpc" "my_vpc"{
  cidr_block = var.vpc_config.cidr_block
  #security_group =
  tags = {
    Name = var.vpc_config.name
}
}

resource "aws_subnet" "sub"{
  for_each = var.subnet_config
  vpc_id = aws_vpc.my_vpc.id
  map_public_ip_on_launch = each.value.public == true ? true : false
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
     Name = each.key
   }
}

resource "aws_route_table" "public_rt" {
  #for_each = {
  #for k, subnet in var.subnet_config:
   # k => subnet if subnet.public
  #}
 vpc_id = aws_vpc.my_vpc.id
  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
tags = {
   Name = "public-rt"
}
}

resource "aws_route_table_association" "public_assoc" {
  #for_each = {
  #  for k, subnet in var.subnet_config:
   #   k => subnet if subnet.public
   #}

#  for_each = aws_subnet.public_subnets
#  subnet_id = aws_subnet.sub[each.key].id
  for_each = local.public_subnets
  subnet_id = each.value.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_internet_gateway"  "igw" {
   vpc_id = aws_vpc.my_vpc.id
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "security group for vpc"
  vpc_id      = aws_vpc.my_vpc.id
  tags = {
    Name = "sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22


}

locals {
  public_subnets = {
    for k, v in aws_subnet.sub: k => v if var.subnet_config[k].public == true
}
private_subnets = {
  for k,v in aws_subnet.sub: k => v if var.subnet_config[k].public == false
}
}


resource "aws_eip" "nat_eip" {

}
resource "aws_nat_gateway" "nat" {
   allocation_id = aws_eip.nat_eip.id
  # subnet_id = aws_subnet.public_subnets[0].id
   subnet_id = values(local.public_subnets)[0].id
   tags = {
     Name = "nat"
}
depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table"  "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
   Name = "private-rt"
}
 }

resource "aws_route_table_association" "private_assoc" {
   for_each = local.private_subnets
   subnet_id = each.value.id
   route_table_id = aws_route_table.private_rt.id
}
