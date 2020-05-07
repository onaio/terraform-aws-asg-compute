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
  type = list
}

variable "target_group_arns" {
  type = list
}

variable "ami" {}
variable "instance_type" {}

variable "cloudwatch_alarm_actions" {
  type = list
}

variable "subnet_ids" {
  type = list
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