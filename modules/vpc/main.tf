
resource "aws_vpc" "eduInsightVpc" { 
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "eduInsightVpc"
    }
}

resource "aws_subnet" "eduInsightPublicSubnet"{
    count = 3
    vpc_id = aws_vpc.eduInsightVpc.id
    cidr_block = cidrsubnet(var.vpc_cidr_block,8,count.index+1)
    availability_zone = element(var.public_subnet_azs, count.index)
    tags = {
        Name = "eduInsightPublicSubnet${count.index+1}"
    }
}

resource "aws_subnet" "private_subnet"{
    count = 2
    vpc_id = aws_vpc.eduInsightVpc.id
    cidr_block = cidrsubnet(var.vpc_cidr_block,8,count.index+4)
    availability_zone = element(var.public_subnet_azs, 0)
    tags = {
        Name = "eduInsightPrivateSubnet${count.index+1}"
    }
}

resource "aws_internet_gateway" "igw" { 
    vpc_id = aws_vpc.eduInsightVpc.id
    tags = {
        Name = "eduInsightIgw"
    }
  
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.eduInsightVpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "eduInsightRouteTable"
    }
}


resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.eduInsightVpc.id
    tags = {
        Name = "eduInsightPrivateRouteTable"
    }
  
}


resource "aws_route_table_association" "private_assoc" {
    count = 2
    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private_rt.id 
}

resource "aws_route_table_association" "public_assoc" {
    count = 3
    subnet_id = aws_subnet.eduInsightPublicSubnet[count.index].id
    route_table_id = aws_route_table.public_rt.id  
}




