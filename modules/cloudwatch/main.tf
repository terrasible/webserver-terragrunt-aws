
resource "aws_cloudwatch_metric_alarm" "main" {
  count                     = var.enabled == true ? 1 : 0
  alarm_name                = var.alarm_name
  alarm_description         = var.alarm_description
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  metric_name               = var.metric_name
  namespace                 = var.namespace
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  alarm_actions             = var.alarm_actions
  actions_enabled           = var.actions_enabled
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  dimensions = var.dimensions
  tags                      = merge(
    { 
      "Name" = format("%s", var.alarm_name)
    },
    var.tags,
  )
  
}