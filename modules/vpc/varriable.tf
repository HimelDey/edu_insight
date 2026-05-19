variable "vpc_cidr_block" {
    description = "vpc cidr block"
}

variable "public_subnet_azs" {
    description = "availability zones for public subnet"
    type = list(string)
}