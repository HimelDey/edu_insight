output "vpc_id" {
    value = aws_vpc.eduInsightVpc.id 
}


output "public_subnet" {
    value = aws_subnet.eduInsightPublicSubnet[*].id
}


output "private_subnet" {
    value = aws_subnet.private_subnet[*].id
}
