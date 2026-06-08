resource "aws_instance" "ec2_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    iam_instance_profile = var.iam_instance_profile
    lifecycle {
      create_before_destroy = true
    }
    #depends_on = [ var.security_group ]
    tags = {
        Name = "ec2-instance"
    }
    user_data = <<-EOF
            #!/bin/bash
            export HOME=/root
            export COMPOSER_HOME=/root/.composer

            # Update system
            dnf update -y
            dnf install git -y
            # Install Apache
            dnf install -y httpd

            # Enable Apache
            systemctl start httpd
            systemctl enable httpd

            # Install PHP 8.2
            # dnf install -y php8.2 php8.2-cli php8.2-common php8.2-mysqlnd php8.2-gd php8.2-mbstring php8.2-xml php8.2-fpm php8.2-zip
            
            dnf install -y php8.3 php8.3-cli php8.3-common php8.3-mysqlnd php8.3-gd php8.3-mbstring php8.3-xml php8.3-fpm php8.3-zip php8.3-bcmath
            # Verify PHP
            php -v

            # Install Composer
            
            php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

            php composer-setup.php --install-dir=/usr/bin --filename=composer

            #rm -f composer-setup.php

            # Verify Composer
            composer --version

            # write httpd rule 
            echo "<VirtualHost *:80>
                ServerName backend-eduinsight.cliqpack.com

                DocumentRoot /var/www/html/eduinsight_backend/public

                <Directory /var/www/html/eduinsight_backend/public>
                    AllowOverride All
                    Require all granted
                </Directory>

                ErrorLog /var/log/httpd/backend-error.log
                CustomLog /var/log/httpd/backend-access.log combined
            </VirtualHost>" > /etc/httpd/conf.d/edu-insight-backend.conf


            # Restart Apache
            systemctl restart httpd

            # Test page
            echo "<?php phpinfo(); ?>" > /var/www/html/index.php

            dnf install nodejs -y
            npm install pm2@latest -g

            chmod -R 775 /var/www/html/eduinsight_backend/storage

            EOF
    user_data_replace_on_change = true 
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
    ingress{
        from_port = 3000
        to_port = 3000    
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


