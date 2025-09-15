module "vpc" {
  source = "./vpc"
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name = "my-vpc"
  }
 subnet_config = {
   public_config = {
    cidr_block = "10.0.1.0/24"
    az = "ap-south-1a"
    public = true
    map_public_ip_on_launch = true
   }
  private_config = {
    cidr_block = "10.0.2.0/24"
    az = "ap-south-1a"
    public = false
  }

}
}

module "ec2" {
  source = "./ec2"
  ec2_config = {
    ami = "ami-02d26659fd82cf299"
    instance_type = "t2.micro"
  }
  security_group_ids = [module.vpc.security_group_id]

  public_subnet_id = module.vpc.public_subnet_ids[0]
  private_subnet_id = module.vpc.private_subnet_ids[0]
}
