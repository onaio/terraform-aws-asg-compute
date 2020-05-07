resource "aws_iam_instance_profile" "ec2" {
  name = "${var.owner}-${var.project_id}-${var.env}-${var.deployed_app}-${var.deployment}"
  role = var.ec2_instance_role
}

resource "aws_launch_configuration" "main" {
  count                       = var.deployed ? 1 : 0
  name_prefix                 = "lc-${var.project_id}-${var.deployment}-"
  image_id                    = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  security_groups             = var.security_groups
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2.name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.attached_volume_size
    delete_on_termination = true
  }

  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  count                = var.deployed ? 1 : 0
  name                 = "asg-${var.project_id}-${var.deployed_app}-${var.deployment}"
  launch_configuration = aws_launch_configuration.main[count.index].name
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  target_group_arns    = var.target_group_arns
  vpc_zone_identifier  = var.subnet_ids

  tags = [
    {
      key                 = "Name"
      value               = "${var.deployed_app}-${var.project}-${var.env}-${var.deployment}-${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "Group"
      value               = "${var.deployed_app}-${var.project}-${var.env}-${var.deployment}"
      propagate_at_launch = true
    },
    {
      key                 = "OwnerList"
      value               = var.owner
      propagate_at_launch = true
    },
    {
      key                 = "EndDate"
      value               = var.end_date
      propagate_at_launch = true
    },
    {
      key                 = "EnvironmentList"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "ProjectList"
      value               = var.project
      propagate_at_launch = true
    },
    {
      key                 = "DeploymentType"
      value               = var.deployment_type
      propagate_at_launch = true
    },
    {
      key                 = "App"
      value               = var.deployed_app
      propagate_at_launch = true
    },
    {
      key                 = "SoftwareVersion"
      value               = var.software_version
      propagate_at_launch = true
    },
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${var.project_id}-${var.deployment}-${var.env}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 600
  threshold           = 95
  statistic           = "Average"
  unit                = "Percent"
  alarm_description   = "Alarms when cpu-utilization is more than 95% for more than 10min for instance with AMI ${var.ami}"

  dimensions = {
    ImageId = var.ami
  }

  alarm_actions = var.cloudwatch_alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "disk_write_bytes" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${var.project_id}-${var.deployment}-${var.env}-disk-writes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskWriteBytes"
  namespace           = "AWS/EC2"
  period              = 3600
  threshold           = 550000000
  statistic           = "Average"
  unit                = "Bytes"
  alarm_description   = "Alarms when disk write is more than 550 mb for more than one hour for instance with AMI ${var.ami}"

  dimensions = {
    ImageId = var.ami
  }

  alarm_actions = var.cloudwatch_alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "network_out" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${var.project_id}-${var.deployment}-${var.env}-network-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 900
  threshold           = 40000000
  statistic           = "Average"
  unit                = "Bytes"
  alarm_description   = "Alarms when Network Out is more than 40000000 for more than 15 mins for instance with AMI ${var.ami}"

  dimensions = {
    ImageId = var.ami
  }

  alarm_actions = var.cloudwatch_alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "network_in" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${var.project_id}-${var.deployment}-${var.env}-network-in"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 900
  threshold           = 400000000
  statistic           = "Average"
  unit                = "Bytes"
  alarm_description   = "Alarms when Network In is more than 400000000 for more than 15 mins for instance with AMI ${var.ami}"

  dimensions = {
    ImageId = var.ami
  }

  alarm_actions = var.cloudwatch_alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "disk_read" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${var.project_id}-${var.deployment}-${var.env}-disk-read"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskReadBytes"
  namespace           = "AWS/EC2"
  period              = 3600
  threshold           = 550000000
  statistic           = "Average"
  unit                = "Bytes"
  alarm_description   = "Alarms when disk read is more than 550 mb for more than one hour for instance with AMI ${var.ami}"

  dimensions = {
    ImageId = var.ami
  }

  alarm_actions = var.cloudwatch_alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "check_failed" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${var.project_id}-${var.deployment}-${var.env}-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  threshold           = 1
  statistic           = "Maximum"
  unit                = "Count"
  alarm_description   = "Alarms when Status Check Failed more than 1 time for more than 1 mins for instance with AMI ${var.ami}"

  dimensions = {
    ImageId = var.ami
  }

  alarm_actions = var.cloudwatch_alarm_actions
}
