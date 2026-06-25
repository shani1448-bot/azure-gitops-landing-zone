resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = var.name
  target_resource_id         = var.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(var.log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(var.metric_categories)

    content {
      category = metric.value
      enabled  = true
    }
  }

  dynamic "metric" {
  for_each = var.metric_categories

  content {
    category = metric.value
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}

dynamic "metric" {
  for_each = var.disabled_metric_categories

  content {
    category = metric.value
    enabled  = false

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}
}