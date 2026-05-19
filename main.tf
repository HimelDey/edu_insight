provider "aws" {
    region = "ap-southeast-1"
}

locals {
    availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

module "eduInsightVpc" {
    source = "./modules/vpc"
    vpc_cidr_block = "10.0.0.0/16"
    public_subnet_azs = local.availability_zones
}

module "eduInsightSecurityGroup" {
    source = "./modules/security_group"
    vpc_id = module.eduInsightVpc.vpc_id
}

module "eduInsightEc2"{
    source = "./modules/ec2"
    ami_id = "ami-0a84a03957476a2cc"
    instance_type = "t2.micro"
    subnet_id = module.eduInsightVpc.private_subnet[0]
    security_group = module.eduInsightSecurityGroup.alb_sg_id
}


module "alb" {
    source = "./modules/alb"
    security_group = module.eduInsightSecurityGroup.alb_sg_id
    public_subnet = [module.eduInsightVpc.public_subnet[0], module.eduInsightVpc.public_subnet[1]]
    vpc_id = module.eduInsightVpc.vpc_id
    instance_id = module.eduInsightEc2.instance_id
}



