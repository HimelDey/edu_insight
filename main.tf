provider "aws" {
    region = "ap-southeast-1"
}

locals {
    availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

data "aws_iam_role" "ec2_role" {
    name = "EduInsightSSMRoleForEc2"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EduInsightSSMRoleForEc2Profile"
  role = data.aws_iam_role.ec2_role.name
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
    instance_type = "t2.medium"
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    vpc_id = module.eduInsightVpc.vpc_id
    subnet_id = module.eduInsightVpc.private_subnet[0]
    security_group = module.eduInsightSecurityGroup.alb_sg_id
}


module "alb" {
    source = "./modules/alb"
    security_group = module.eduInsightSecurityGroup.alb_sg_id
    certificate_arn = var.certificate_arn
    public_subnet = [module.eduInsightVpc.public_subnet[0], module.eduInsightVpc.public_subnet[1]]
    vpc_id = module.eduInsightVpc.vpc_id
    instance_id = module.eduInsightEc2.instance_id
}



