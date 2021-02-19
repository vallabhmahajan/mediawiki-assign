variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "availability_zone" {
  type = "list"
}
variable "vpc_id" {}
variable "private_subnet_id_1" {}
variable "public_cidr_block" {
  type = "list"
}