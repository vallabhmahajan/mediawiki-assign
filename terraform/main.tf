module "productstack" {
  source = "./modules/productstack"
  vpc_cidr = "${var.vpc_cidr}"
  availability_zone = "${var.availability_zone}"
  public_cidr_block = "${var.public_cidr_block}"
  private_cidr_block = "${var.private_cidr_block}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
}

module "apptier" {
  source = "./modules/softwarestack/apptier"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${module.productstack.key_name}"
  vpc_id = "${module.productstack.vpc_id}"
  public_subnet_ids = "${module.productstack.public_subnet_ids}"
  availability_zone = "${var.availability_zone}"
  desired_count = "${var.desired_count}"
  scale_min = "${var.scale_min}"
  scale_max = "${var.scale_max}"
}

module "dbtier" {
  source = "./modules/softwarestack/dbtier"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${module.productstack.key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_id = "${module.productstack.vpc_id}"
  private_subnet_id_1 = "${module.productstack.private_subnet_id_1}"
  public_cidr_block = "${var.public_cidr_block}"
}

module "jumpserver" {
  source = "./modules/softwarestack/jumpserver"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${module.productstack.key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_id = "${module.productstack.vpc_id}"
  public_subnet_ids = "${module.productstack.public_subnet_ids}"
}