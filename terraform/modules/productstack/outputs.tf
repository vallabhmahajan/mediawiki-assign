# Outputs
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.subnet-public.*.id}"
}

output "private_subnet_id_1" {
  value = "${aws_subnet.subnet-private.id}"
}

output "key_name" {
  value = "${aws_key_pair.pemkey.key_name}"
}