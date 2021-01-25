output "id" {
  value       = aws_cloudwatch_metric_alarm.main.*.id 
  description = "The ID of the health check."
}

output "arn" {
  value       = aws_cloudwatch_metric_alarm.main.*.arn
  description = "The ARN of the cloudwatch metric alarm."
}
