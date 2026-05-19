resource "aws_instance" "ec2_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids = [var.security_group]
    lifecycle {
      create_before_destroy = true
    }
    depends_on = [ var.security_group ]
    tags = {
        Name = "ec2-instance"
    }
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World!" > /var/www/html/index.html
                EOF
}