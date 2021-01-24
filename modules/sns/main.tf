resource "aws_sns_topic" "sns" {
  name = var.name
  tags = merge(
    { 
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}


variable "name" {
  type=string
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
}

output "id" {
  value= aws_sns_topic.sns.id
}

output "arn" {
  value= aws_sns_topic.sns.arn
}