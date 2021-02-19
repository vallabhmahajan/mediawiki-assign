variable "vpc_id" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "availability_zone" {
  type = "list"
}
variable "public_subnet_ids" {
  type = "list"
}