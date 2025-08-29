module "backend" {
    source = "terraform-aws-modules/ec2-instance/aws"
    create_security_group = false #as the module is taken from internet it already contains it's own SG, but we already have our own SGs, in order to avoid new SG, setting the new SG to false
    name = "${var.project_name}-${var.environment}-backend"
    ami = data.aws_ami.ami_info.id
    subnet_id = local.private_subnet_id
    instance_type = "t3.micro"
    vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-backend"
        }
    )
}

module "frontend" {
    source = "terraform-aws-modules/ec2-instance/aws"
    create_security_group = false #as the module is taken from internet it already contains it's own SG, but we already have our own SGs, in order to avoid new SG, setting the new SG to false
    name = "${var.project_name}-${var.environment}-frontend"
    ami = data.aws_ami.ami_info.id
    subnet_id = local.public_subnet_id
    instance_type = "t3.micro"
    vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-public"
        }
    )
}

module "ansible" {
    source = "terraform-aws-modules/ec2-instance/aws"
    create_security_group = false #as the module is taken from internet it already contains it's own SG, but we already have our own SGs, in order to avoid new SG, setting the new SG to false
    name = "${var.project_name}-${var.environment}-ansible"
    ami = data.aws_ami.ami_info.id
    subnet_id = local.public_subnet_id
    user_data = file("expense.sh")
    instance_type = "t3.micro"
    vpc_security_group_ids = [data.aws_ssm_parameter.ansible_sg_id.value]
    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-ansible"
        }
    )
    depends_on = [ module.backend,module.frontend ] #while we launch theese servers, ingeneral all the servers will be launched parllelly and ansible starts configuring, if incase ansible gets launched first and it tries to connect to remaining servers and gets fail. So, we use depends on command, then after launching all the remaining ansible gets launched.
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "backend"
      type    = "A"
      ttl     = 1
      records = [
        module.backend.private_ip
      ]
    },
    {
      name    = "frontend"
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.private_ip
      ]
    },
    {
      name    = ""#domain name
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.public_ip
      ]
    }
  ]
}