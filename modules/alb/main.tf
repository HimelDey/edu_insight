resource "aws_alb" "application_load_balancer" {
    name = "application-load-balancer"
    internal = false
    security_groups = [var.security_group]
    subnets = var.public_subnet
    tags = {
        Name = "application-load-balancer"
    } 
}

resource "aws_alb_target_group" "edu-i-be-tg" {
    name = "edu-i-be-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "instance"
    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 5
        unhealthy_threshold = 2
    }
}


resource "aws_alb_target_group" "edu-i-fe-tg" {
    name = "edu-i-fe-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "instance"
    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 5
        unhealthy_threshold = 2
    }
}


resource "aws_alb_target_group_attachment" "alb_target_group_attachment" {
    target_group_arn = aws_alb_target_group.edu-i-be-tg.arn
    target_id = var.instance_id
    port = 80
    depends_on = [var.instance_id]
}






resource "aws_alb_target_group_attachment" "alb_target_group_attachment_frontend" {
    target_group_arn = aws_alb_target_group.edu-i-fe-tg.arn
    target_id = var.instance_id
    port = 3000
    depends_on = [var.instance_id]
}



resource "aws_alb_listener" "alb_backend_listener" {
    load_balancer_arn = aws_alb.application_load_balancer.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_alb_target_group.edu-i-be-tg.arn
    }
   
  
}


# resource "aws_alb_listener" "alb_backend_listener2" {
#     load_balancer_arn = aws_alb.application_load_balancer.arn
#     port = 443
#     protocol = "HTTPS"
#     certificate_arn = var.certificate_arn
#     default_action {
#         type = "forward"
#         target_group_arn = aws_alb_target_group.edu-i-be-tg.arn
#     }
   
  
# }


resource "aws_alb_listener" "alb_https_listener" {
    load_balancer_arn = aws_alb.application_load_balancer.arn
    port = 443
    certificate_arn = var.certificate_arn
    protocol = "HTTPS"
    default_action {
      type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "Not Found"
            status_code  = "404"
        }
    }
   
  
}

resource "aws_alb_listener_rule" "listener_rule_backend_http" {
    listener_arn = aws_alb_listener.alb_backend_listener.arn
    priority = 100
    action {
        type = "forward"
        target_group_arn = aws_alb_target_group.edu-i-be-tg.arn
    }
     condition {
        host_header {
            values = ["backend-eduinsight.cliqpack.com"]
        }
    }
  
}


resource "aws_alb_listener_rule" "listener_rule_backend_https" {
    listener_arn = aws_alb_listener.alb_https_listener.arn
    priority = 200
    action {
        type = "forward"
        target_group_arn = aws_alb_target_group.edu-i-be-tg.arn
    }
    condition {
        host_header {
            values = ["backend-eduinsight.cliqpack.com"]
        }
    }
  
}


resource "aws_alb_listener_rule" "listener_rule_frontend" {
    listener_arn = aws_alb_listener.alb_https_listener.arn
    priority = 100
    action {
        type = "forward"
        target_group_arn = aws_alb_target_group.edu-i-fe-tg.arn
    }
    condition {
        host_header {
            values = ["frontend-eduinsight.cliqpack.com"]
        }
    }
  
}



