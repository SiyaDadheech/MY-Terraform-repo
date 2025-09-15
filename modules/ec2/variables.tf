variable "ec2_config" {
   type = object({

    ami = string
    instance_type = string
})
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
   type = string
}
