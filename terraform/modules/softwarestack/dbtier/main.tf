resource "aws_ebs_volume" "volume" {
  availability_zone = "${var.availability_zone[0]}"
  size = 20
}

resource "aws_security_group" "security-group" {
  vpc_id = "${var.vpc_id}"

  ingress {
    description = "SSH"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = "${var.public_cidr_block}"
  }

  ingress {
    description = "Enable DB Port"
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    cidr_blocks = "${var.public_cidr_block}"
  }

  ingress {
    description = "Ping"
    from_port = -1
    protocol = "ICMP"
    to_port = -1
    cidr_blocks = "${var.public_cidr_block}"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mediawiki-db-sec-group"
    Automation = "Terraform"
  }
}

resource "aws_instance" "dbserver" {
  ami             = "${var.ami}"
  availability_zone = "${var.availability_zone[0]}"
  instance_type   = "${var.instance_type}"
  vpc_security_group_ids  = ["${aws_security_group.security-group.id}"]
  subnet_id	  = "${var.private_subnet_id_1}"
  associate_public_ip_address = false
  key_name = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install epel-release yum-utils -y
              sudo yum install python3 python3-pip python3-setuptools -y
              sudo python3 -m pip install --upgrade pip setuptools wheel
              sudo yum install mariadb-server mariadb wget telnet -y
              sudo systemctl enable mariadb
              sudo systemctl start mariadb
              EOF
  tags = {
    Name = "mediawiki-dbserver"
  }

}

resource "aws_volume_attachment" "attach_volume" {
  device_name = "/dev/sdb"
  instance_id = "${aws_instance.dbserver.id}"
  volume_id = aws_ebs_volume.volume.id
}