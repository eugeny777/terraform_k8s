data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}



resource "aws_subnet" "kube_private_subnet" {
#  vpc_id                  = var.kube_vpc
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = "eu-west-1a"
  cidr_block              = var.cidr
}


module "firewall_ec2" {
  source = "./modules/firewall"
  name        = "main-sg"
  vpc_id      = data.aws_vpc.default.id
}






module "master" {
  source                      = "./modules/ec"
  vpc_security_group_ids      = [module.firewall_ec2.this_security_group_id]
  subnet_id                   =  aws_subnet.kube_private_subnet.id
  count_instance = 1
  tags   = {
    app = "master-node"
    env = "stage"
  }
}


module worker {
  source = "./modules/ec"
  vpc_security_group_ids      = [module.firewall_ec2.this_security_group_id]
  subnet_id                   =  aws_subnet.kube_private_subnet.id
  count_instance = 2 
  tags   = {
    app = "worker-node"
    env = "stage"
  }
}


resource "null_resource" "run-ansible-playbook-master" {
  provisioner "local-exec" {
    command = "sleep 75 && ansible-playbook -i ../ansible/inventory_aws_ec2.yml   --extra-vars \"node=app_master_node\" ../ansible/install_k8s.yml  --ssh-common-args='-o StrictHostKeyChecking=no'  --private-key ~/.ssh/root.pem"
  }
  depends_on = [module.master]
}

resource "null_resource" "run-ansible-playbook" {
  provisioner "local-exec" {
    command = "sleep 75 && ansible-playbook -i ../ansible/inventory_aws_ec2.yml --extra-vars  \"node=app_worker_node\" ../ansible/install_k8s.yml  --ssh-common-args='-o StrictHostKeyChecking=no'  --private-key ~/.ssh/root.pem"
  }
  depends_on = [module.worker]
}
