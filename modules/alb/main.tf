resource "aws_alb" "application_load_balancer" {
    name = "application-load-balancer"
    internal = false
    security_groups = [var.security_group]
    subnets = var.public_subnet
    tags = {
        Name = "application-load-balancer"
    } 
}

resource "aws_alb_target_group" "target_group" {
    name = "target-group"
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
    target_group_arn = aws_alb_target_group.target_group.arn
    target_id = var.instance_id
    port = 80
    depends_on = [var.instance_id]
}


resource "aws_alb_listener" "alb_listener" {
    load_balancer_arn = aws_alb.application_load_balancer.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_alb_target_group.target_group.arn
    }
  
}



