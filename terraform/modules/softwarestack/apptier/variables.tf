variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = "list"
}
variable "availability_zone" {
  type = "list"
}
variable "desired_count" {}
variable "scale_min" {}
variable "scale_max" {}