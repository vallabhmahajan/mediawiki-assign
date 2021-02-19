# Security Group for Jumpserver
resource "aws_security_group" "security-group" {
  vpc_id = "${var.vpc_id}"

  ingress {
    description = "SSH"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jumpserver-sec-group"
    Automation = "Terraform"
  }
}

# Create jumpserver ec2 instance
resource "aws_instance" "jumpserver" {
  ami             = "${var.ami}"
  availability_zone = "${var.availability_zone[0]}"
  instance_type   = "${var.instance_type}"
  vpc_security_group_ids  = ["${aws_security_group.security-group.id}"]
  subnet_id	  = "${var.public_subnet_ids[0]}"
  associate_public_ip_address = true
  key_name = "${var.key_name}"
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install epel-release yum-utils -y
              sudo yum install python3 python3-pip python3-setuptools -y
              sudo python3 -m pip install --upgrade pip setuptools wheel
              sudo pip3 install setuptools-rust
              sudo pip3 install ansible==2.7.7
              EOF
  tags = {
    Name = "jumpserver"
    Automation = "Terraform"
  }

}