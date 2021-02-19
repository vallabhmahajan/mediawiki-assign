variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "ami" {}
variable "vpc_cidr" {}
variable "private_cidr_block" {}
variable "instance_type" {}
variable "availability_zone" {
  type = "list"
}
variable "public_cidr_block" {
  type = "list"
}
variable "desired_count" {}
variable "scale_min" {}
variable "scale_max" {}