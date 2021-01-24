variable "autoscaling_group_name" {
  description = "List of target IDs"
  type        = string
}

variable "alb_target_group_arn" {
  description = "The port on which targets receive traffic"
  type        = string
}