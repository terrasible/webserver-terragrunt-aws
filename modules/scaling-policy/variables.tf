variable "name" {
  description = "The name of the policy"
  type        = string
  default     = ""
}
variable "scaling_adjustment" {
  type    = number
  default = 4
}
variable "adjustment_type" {
  type    = string
  default = "ChangeInCapacity"
}
variable "cooldown" {
  type    = number
  default = 300

}
variable "autoscaling_group_name" {
  description = "The name of the autoscaling group"
  type        = string
}