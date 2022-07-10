data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "codin-asg" {
  launch_configuration = "${aws_launch_configuration.codin-ec2.name}"
  vpc_zone_identifier = [aws_subnet.lb-Subnet1.id, aws_subnet.lb-Subnet2.id, aws_subnet.lb-Subnet3.id]

  min_size = 3
  max_size = 9
  target_group_arns = ["${aws_lb_target_group.codin-lbtg.arn}"]

  #load_balancers            = ["${aws_lb.nlb.name}"]
  #health_check_type         = "ELB"
  wait_for_capacity_timeout = "5m"

  tag {
    key                 = "Name"
    value               = "codin-ec2"
    propagate_at_launch = true
  }
}

###create key
resource "aws_key_pair" "mykeypair" {
  key_name = "picterra"
  public_key = "${file("${var.PUBLIC_KEY}")}"
  lifecycle {
    ignore_changes = [public_key]
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAUNCH CONFIGURATION THAT DEFINES EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "codin-ec2" {
  # AWS Linux AMI (HVM), SSD Volume Type in us-east-2
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.codin-inssg.id}"]
  key_name      = "${aws_key_pair.mykeypair.key_name}"
  associate_public_ip_address = "true"
  user_data = <<-EOF
#!/bin/bash
sudo apt -get update
sudo apt install -y apache2
sudo systemctl status apache2
sudo systemctl start apache2
sudo chown -R $USER:$USER /var/www/html
sudo echo "<html><body><h1> Hello tf team <h1></body></html>" > /var/www/html/index.html
EOF

# This device contains homePath
  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_size           = 8
    volume_type           = "gp2"
#    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/xvdc"
    volume_size           = 8
    volume_type           = "gp2"
#    encrypted             = true
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

