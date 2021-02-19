output "jumpserver_public_ip" {
  value = "${aws_instance.jumpserver.public_ip}"
}