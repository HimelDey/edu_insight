resource "aws_instance" "ec2_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    lifecycle {
      create_before_destroy = true
    }
    depends_on = [ var.security_group ]
    tags = {
        Name = "ec2-instance"
    }
    user_data = <<-EOF
                #!/bin/bash

                # Update system
                dnf update -y

                # Install Apache
                dnf install -y httpd

                # Enable Apache
                systemctl start httpd
                systemctl enable httpd

                # Install PHP 8.2
                dnf install -y php8.2 php8.2-cli php8.2-common php8.2-mysqlnd php8.2-gd php8.2-mbstring php8.2-xml php8.2-fpm php8.2-zip

                # Verify PHP
                php -v

                # Install Composer
                cd /tmp

                php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

                php composer-setup.php --install-dir=/usr/local/bin --filename=composer

                rm -f composer-setup.php

                # Verify Composer
                composer --version

                # Restart Apache
                systemctl restart httpd

                # Test page
                echo "<?php phpinfo(); ?>" > /var/www/html/index.php

                EOF
}

resource "aws_security_group" "ec2_sg" {
    name = "ec2-security-group"
    vpc_id = var.vpc_id
    description = "Security group for EC2 instance"
    ingress{
        from_port = 80
        to_port = 80    
        protocol = "tcp"
        security_groups = [var.security_group]
    }
    ingress{
        from_port = 22
        to_port = 22    
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        from_port = 443
        to_port = 443    
        protocol = "tcp"
        security_groups = [var.security_group]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
      
  
}


