resource "aws_security_group" "security-group" {
  vpc_id = "${var.vpc_id}"

  ingress {
    description = "SSH"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Enable HTTP Port"
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Ping"
    from_port = -1
    protocol = "ICMP"
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mediawiki-app-sec-group"
    Automation = "Terraform"
  }
}

resource "aws_launch_configuration" "launch_config" {
  name = "mediawiki-launch-config"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.security-group.id}"]
  associate_public_ip_address = false
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 20
    volume_type = "gp2"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install epel-release yum-utils -y
              sudo yum install python3 python3-pip python3-setuptools -y
              sudo python3 -m pip install --upgrade pip setuptools wheel
              sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
              sudo yum-config-manager --enable remi-php73
              sudo yum install httpd httpd-devel php php-common php-mbstring php-mysqlnd php-gd php-xml mariadb-server mariadb wget telnet -y
              EOF
}

# Create a new load balancer
resource "aws_elb" "elb" {
  name               = "mediawiki-elb"
  subnets = "${var.public_subnet_ids}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/mediawiki/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "mediawiki-elb"
  }

}

resource "aws_autoscaling_group" "auto_scale" {
  name = "mediawiki-auto-scale-group"
  launch_configuration = "${aws_launch_configuration.launch_config.name}"
  max_size = "${var.scale_max}"
  min_size = "${var.scale_min}"
  desired_capacity = "${var.desired_count}"
  health_check_grace_period = 300
  health_check_type = "ELB"
  lifecycle {
    create_before_destroy = true
  }
  vpc_zone_identifier = "${var.public_subnet_ids}"
  tag {
    key = "Role"
    value = "appserver"
    propagate_at_launch = true
  }

  load_balancers = ["${aws_elb.elb.id}"]

  depends_on = ["aws_elb.elb"]
}