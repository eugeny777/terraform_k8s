 resource "aws_instance" "node"  {
    count                       = var.count_instance
    instance_type               = var.instance_type
    vpc_security_group_ids      = var.vpc_security_group_ids
    subnet_id                   = var.subnet_id
    ami                         = data.aws_ami.centos.id
    key_name                    = "root"
    associate_public_ip_address = "true"
    tags = var.tags
  }

  data "aws_ami" "centos" {
    owners      = ["679593333241"]
    most_recent = true
    filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}
