output "public_subnet_ids" {
  value = [
          for k,s in aws_subnet.sub:
            s.id if lookup(var.subnet_config[k],"public",false)
  ]
}

output "private_subnet_ids" {
   value = [
     for k, s in aws_subnet.sub:
         s.id if !lookup(var.subnet_config[k],"public",false)
   ]
}


output "public_route_table_ids" {
#   value = { for k, rt in aws_route_table.public_rt : k => rt.id }
    value = aws_route_table.public_rt
}


output "security_group_id" {
   value = aws_security_group.sg.id
}
