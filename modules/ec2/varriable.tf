variable "ami_id" {
  description = "AMI ID"
}

variable "instance_type" {
  description = "Instance type"
}

variable "subnet_id" {
    description = "Subnet ID"
}

variable "security_group" {
  description = "Security group"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "iam_instance_profile" {
  description = "IAM instance profile"
  
}