# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN NLB TO ROUTE TRAFFIC ACROSS THE AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "codin-nlb" {
  name               = "codin-nlb"
  load_balancer_type = "network"
  #security_groups    = ["${aws_security_group.lb.id}"]
  subnets             = [aws_subnet.lb-Subnet1.id, aws_subnet.lb-Subnet2.id, aws_subnet.lb-Subnet3.id ]
  enable_cross_zone_load_balancing = true
  #health_check {
    #healthy_threshold = 5
    #unhealthy_threshold = 5
    #timeout = 3
    #interval = 30
    #target = "HTTP:80/"
   #}

  # This adds a listener for incoming HTTP requests.
  #listener {
    #lb_port           = 80
    #lb_protocol       = "http"
    #instance_port     = "80"
    #instance_protocol = "http"
  #}
}
resource "aws_lb_target_group" "codin-lbtg" {
  name     = "TG-terra"
  port     = "80"
  protocol = "TCP"
  vpc_id   = aws_vpc.codinlb-VPC.id
  deregistration_delay = "300"
  #health_check {
    #healthy_threshold = 5
    #unhealthy_threshold = 5
    #timeout = 3
    #interval = 30
   #}
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.codin-nlb.arn}"
  port              = "80"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.codin-lbtg.arn}"
    type             = "forward"
  }
}
