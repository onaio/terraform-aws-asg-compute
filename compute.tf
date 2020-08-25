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
  name                 = "asg-${var.project_id}-${var.env}-${var.deployed_app}-${var.deployment}"
  launch_configuration = aws_launch_configuration.main[count.index].name
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  target_group_arns    = var.target_group_arns
  vpc_zone_identifier  = var.subnet_ids

  lifecycle {
    create_before_destroy = true
  }

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
  alarm_name          = "${aws_autoscaling_group.main[0].name}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_metric_evaluation_number_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cloudwatch_metric_evaluation_period_length
  threshold           = var.cloudwatch_cpu_utilization_threshold
  statistic           = "Average"
  unit                = "Percent"
  alarm_description   = "Alarms when CPU utilization is more than 90% for more than 3 * 60 seconds for instances in ASG ${aws_autoscaling_group.main[0].name}"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main[0].name
  }

  alarm_actions             = var.cloudwatch_alarm_actions
  ok_actions                = var.cloudwatch_ok_actions
  insufficient_data_actions = var.cloudwatch_insufficient_data_actions
}

resource "aws_cloudwatch_metric_alarm" "mem_utilization" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${aws_autoscaling_group.main[0].name}-mem-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_metric_evaluation_number_periods
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = var.cloudwatch_metric_evaluation_period_length
  threshold           = var.cloudwatch_memory_utilization_threshold
  statistic           = "Average"
  unit                = "Percent"
  alarm_description   = "Alarms when memory utilization is more than 90% for more than 3 * 60 seconds for instances in ASG ${aws_autoscaling_group.main[0].name}"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main[0].name
  }

  alarm_actions             = var.cloudwatch_alarm_actions
  ok_actions                = var.cloudwatch_ok_actions
  insufficient_data_actions = var.cloudwatch_insufficient_data_actions
}

resource "aws_cloudwatch_metric_alarm" "check_failed" {
  count               = var.deployed ? 1 : 0
  alarm_name          = "${aws_autoscaling_group.main[0].name}-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_metric_evaluation_number_periods
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = var.cloudwatch_metric_evaluation_period_length
  threshold           = 1
  statistic           = "Maximum"
  unit                = "Count"
  alarm_description   = "Alarms when Status Check failed more than 1 time for more than 3 * 60 seconds for instances in ASG ${aws_autoscaling_group.main[0].name}"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main[0].name
  }

  alarm_actions             = var.cloudwatch_alarm_actions
  ok_actions                = var.cloudwatch_ok_actions
  insufficient_data_actions = var.cloudwatch_insufficient_data_actions
}
