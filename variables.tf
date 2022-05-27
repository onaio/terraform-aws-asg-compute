variable "deployment" {}
variable "env" {}
variable "project" {}
variable "project_id" {}
variable "deployment_type" {
  type        = string
  default     = "vm"
  description = "The deployment type the resources brought up by this module are part of."
}
variable "owner" {}
variable "end_date" {}
variable "deployed" {}
variable "ssh_key_name" {}
variable "asg_max_size" {}
variable "asg_min_size" {}

variable "security_groups" {
  type = list(any)
}

variable "target_group_arns" {
  type = list(any)
}

variable "ami" {}
variable "instance_type" {}

variable "cloudwatch_alarm_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "cloudwatch_ok_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "cloudwatch_insufficient_data_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "cloudwatch_metric_evaluation_number_periods" {
  type        = number
  default     = 3
  description = "The number of periods for a CloudWatch metric that should be checked before an alarm is raised."
}

variable "cloudwatch_metric_evaluation_period_length" {
  type        = number
  default     = 60
  description = "The length of each of the CloudWatch metric periods for the alarms being set."
}

variable "cloudwatch_cpu_utilization_threshold" {
  type        = number
  default     = 80
  description = "The threshold, in percentage, of CPU utilization for the auto-scaling group which when crossed an alarm will be raised."
}

variable "cloudwatch_memory_utilization_threshold" {
  type        = number
  default     = 80
  description = "The threshold, in percentage, of memory utilization for the auto-scaling group which when crossed an alarm will be raised."
}

variable "subnet_ids" {
  type = list(any)
}

variable "user_data" {}
variable "deployed_app" {}
variable "attached_volume_size" {}

variable "software_version" {
  default = "master"
}

variable "ec2_instance_role" {
  type        = string
  description = "The name of the IAM role to attach to the EC2 instances"
  default     = "EC2UpdateInstanceTags"
}
