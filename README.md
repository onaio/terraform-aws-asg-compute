# Auto-Scaling Compute Terraform module

s module creates an aws launch configuration, an aws auto-scaling group and cloudwatch alarms for the auto-scaling group. It also allows for a blue green deployment if the module is imported twice under a blue and a green configuration name.

## Usage Example

```hcl

module "rapidpro-blue" {
  source = "../../modules/asg-compute"

  asg_max_size             = "${var.blue_asg_max_size}"
  asg_min_size             = "${var.blue_asg_min_size}"
  deployment               = "blue"
  deployed                 = "${var.deploy_blue}"
  env                      = "${var.env}"
  project                  = "${var.project}"
  project_id               = "${var.project_id}"
  owner                    = "${var.owner}"
  end_date                 = "${var.end_date}"
  ssh_key_name             = "${var.ssh_key_name}"
  ami                      = "${var.blue_ami}"
  instance_type            = "${var.instance_type}"
  attached_volume_size     = "${var.attached_volume_size}"
  cloudwatch_alarm_actions = "${var.cloudwatch_alarm_actions}"
  target_group_arns        = "${module.rapidpro.target_group_arns}"
  security_groups          = "${module.rapidpro.security_groups}"
  subnet_ids               = "${module.rapidpro-vpc.subnet_ids}"
  user_data                = "${data.template_cloudinit_config.rapidpro.rendered}"
}

module "rapidpro-green" {
  source = "../../modules/asg-compute"

  asg_max_size             = "${var.green_asg_max_size}"
  asg_min_size             = "${var.green_asg_min_size}"
  deployment               = "green"
  deployed                 = "${var.deploy_green}"
  env                      = "${var.env}"
  project                  = "${var.project}"
  project_id               = "${var.project_id}"
  owner                    = "${var.owner}"
  end_date                 = "${var.end_date}"
  ssh_key_name             = "${var.ssh_key_name}"
  ami                      = "${var.green_ami}"
  instance_type            = "${var.instance_type}"
  attached_volume_size     = "${var.attached_volume_size}"
  cloudwatch_alarm_actions = "${var.cloudwatch_alarm_actions}"
  target_group_arns        = "${module.rapidpro.target_group_arns}"
  security_groups          = "${module.rapidpro.security_groups}"
  subnet_ids               = "${module.rapidpro-vpc.subnet_ids}"
  user_data                = "${data.template_cloudinit_config.rapidpro.rendered}"
}
```

A cloudinit config template can be provided for the auto-scaling group instances. For example:

```hcl

data "template_cloudinit_config" "rapidpro" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"

    content = <<-EOF
      #!/bin/bash
      . /home/rapidpro/.virtualenvs/rapidpro/bin/activate
      . /home/rapidpro/app/django.sh
      cd /home/rapidpro/app
      python manage.py migrate --noinput
      python manage.py collectstatic --noinput
      systemctl reload nginx.service
      systemctl enable rapidpro.service
      systemctl start rapidpro.service
      EOF
  }
}
```

## Note on IAM Role

Make sure the EC2 instances that are created using this module are attached to an IAM role (using the `ec2_instance_role` variable) that has the following permissions:

  - ec2:DeleteTags
  - ec2:CreateTags
  - All ec2:Describe* permissions

These permissions are needed by [sre-tooling](https://github.com/onaio/sre-tooling) to update the details of the tags of the instances from within the instances.
