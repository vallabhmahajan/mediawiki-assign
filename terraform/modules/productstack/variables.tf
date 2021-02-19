variable "vpc_cidr" {}
variable "private_cidr_block" {}
variable "ami" {}
variable "instance_type" {}
variable "availability_zone" {
  type = "list"
}
variable "public_cidr_block" {
  type = "list"
}