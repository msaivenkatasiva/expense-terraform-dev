###creating database security-group(firewall)
module "db" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for DB MYSQL Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "db"
}

###creating backend security-group(firewall)
module "backend" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for Backend Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "backend"
}

###creating frontend security-group(firewall)
module "frontend" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for Frontend Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "frontend"
}

###creating bastion security-group(firewall)
module "bastion" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for bastion Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "bastion"
}

###creating ansible security-group(firewall)
module "ansible" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for ansible Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "ansible"
}


###DB servers are accepting traffic from backend servers
resource "aws_security_group_rule" "db_from_backend" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.backend.sg_id
    security_group_id = module.db.sg_id
} 

resource "aws_security_group_rule" "db_from_bastion" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.bastion.sg_id
    security_group_id = module.db.sg_id
} 

###backend servers are accepting traffic from frontend
resource "aws_security_group_rule" "backend_from_frontend" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_from_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_from_ansible" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.backend.sg_id
}

###frontend servers are accepting traffic from public
resource "aws_security_group_rule" "frontend_from_public" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_from_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_from_ansible" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.frontend.sg_id
}

###bastion servers are accepting traffic from public
resource "aws_security_group_rule" "bastion_from_public" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

###bastion servers are accepting traffic from public
resource "aws_security_group_rule" "ansible_from_public" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.ansible.sg_id
}

# note: As we've created SGs and created ingressrules which traffic have to be allowed to related server.Now right after creating the SGs, update those in the parameter store. So, those'd be used by the team who gonna create servers using these SG IDs.