variable "enabled" {
  type        = bool
  default     = true
  description = "Enable alarm."
}

variable "alarm_name" {
  type        = string
  description = "The descriptive name for the alarm."
}

variable "alarm_description" {
  type        = string
  default     = ""
  description = "The description for the alarm."
}

variable "comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold."
}

variable "evaluation_periods" {
  type        = number
  default     = 2
  description = "The number of periods over which data is compared to the specified threshold."
}
variable "metric_name" {
  type        = string
  default     = "CPUUtilization"
  description = "The name for the alarm's associated metric."
}

variable "namespace" {
  type        = string
  default     = "AWS/EC2"
  description = "The namespace for the alarm's associated metric."
}

variable "period" {
  type        = number
  default     = 120
  description = "The period in seconds over which the specified statistic is applied."
}
variable "statistic" {
  type        = string
  default     = "Average"
  description = "The statistic to apply to the alarm's associated metric."
}

variable "threshold" {
  type        = number
  default     = 40
  description = "The value against which the specified statistic is compared."
}
variable "actions_enabled" {
  type        = bool
  default     = true
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state."
}

variable "insufficient_data_actions" {
  type        = list(any)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state."
}
variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
}
variable "dimensions" {
  type        = map(string)
  default     = {}
  description = "Dimensions for metrics."
}

variable "ok_actions" {
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state."
  type        = list(any)
  default     = []
}

variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state."
  type        = list(any)
  default     = []
}