resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_secret_near_expiry" {
  count = var.enable_alerting == true && var.secret_near_expiry_alert != null ? 1 : 0

  name                = "${azurerm_key_vault.keyvault.name}-secret-near-expiry"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  location            = var.location

  evaluation_frequency = var.secret_near_expiry_alert.evaluation_frequency
  window_duration      = var.secret_near_expiry_alert.window_duration
  scopes               = [azurerm_key_vault.keyvault.id]
  severity             = 2

  criteria {
    query = <<-QUERY
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName contains "SecretNearExpiry"
| project
    SecretName = column_ifexists("eventGridEventProperties_data_ObjectName_s","")
| summarize Events=count() by SecretName
QUERY

    time_aggregation_method = "Total"
    threshold               = var.secret_near_expiry_alert.threshold
    operator                = "GreaterThanOrEqual"

    resource_id_column    = "SecretName"
    metric_measure_column = "Events"

    dimension {
      name     = "SecretName"
      operator = "Include"
      values   = ["*"]
    }
  }

  description = "The Key Vault secret is nearing expiration."

  action {
    action_groups = [var.action_group_id]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_secret_expired" {
  count = var.enable_alerting == true && var.secret_expired_alert != null ? 1 : 0

  name                = "${azurerm_key_vault.keyvault.name}-secret-expired"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  location            = var.location

  evaluation_frequency = var.secret_expired_alert.evaluation_frequency
  window_duration      = var.secret_expired_alert.window_duration
  scopes               = [azurerm_key_vault.keyvault.id]
  severity             = 2

  criteria {
    query = <<-QUERY
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName contains "SecretExpired"
| project
    SecretName = column_ifexists("eventGridEventProperties_data_ObjectName_s","")
| summarize Events=count() by SecretName
QUERY

    time_aggregation_method = "Total"
    threshold               = var.secret_expired_alert.threshold
    operator                = "GreaterThanOrEqual"

    resource_id_column    = "SecretName"
    metric_measure_column = "Events"

    dimension {
      name     = "SecretName"
      operator = "Include"
      values   = ["*"]
    }
  }

  description = "The Key Vault secret has expired."

  action {
    action_groups = [var.action_group_id]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_certificate_near_expiry" {
  count = var.enable_alerting == true && var.certificate_near_expiry_alert != null ? 1 : 0

  name                = "${azurerm_key_vault.keyvault.name}-certificate-near-expiry"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  location            = var.location

  evaluation_frequency = var.certificate_near_expiry_alert.evaluation_frequency
  window_duration      = var.certificate_near_expiry_alert.window_duration
  scopes               = [azurerm_key_vault.keyvault.id]
  severity             = 2

  criteria {
    query = <<-QUERY
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName contains "CertificateNearExpiry"
| project
    CertificateName = column_ifexists("eventGridEventProperties_data_ObjectName_s","")
| summarize Events=count() by CertificateName
QUERY

    time_aggregation_method = "Total"
    threshold               = var.certificate_near_expiry_alert.threshold
    operator                = "GreaterThanOrEqual"

    resource_id_column    = "CertificateName"
    metric_measure_column = "Events"

    dimension {
      name     = "CertificateName"
      operator = "Include"
      values   = ["*"]
    }
  }

  description = "The Key Vault certificate is nearing expiration."

  action {
    action_groups = [var.action_group_id]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_certificate_expired" {
  count = var.enable_alerting == true && var.certificate_expired_alert != null ? 1 : 0

  name                = "${azurerm_key_vault.keyvault.name}-certificate-expired"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  location            = var.location

  evaluation_frequency = var.certificate_expired_alert.evaluation_frequency
  window_duration      = var.certificate_expired_alert.window_duration
  scopes               = [azurerm_key_vault.keyvault.id]
  severity             = 2

  criteria {
    query = <<-QUERY
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName contains "CertificateExpired"
| project
    CertificateName = column_ifexists("eventGridEventProperties_data_ObjectName_s","")
| summarize Events=count() by CertificateName
QUERY

    time_aggregation_method = "Total"
    threshold               = var.certificate_expired_alert.threshold
    operator                = "GreaterThanOrEqual"

    resource_id_column    = "CertificateName"
    metric_measure_column = "Events"

    dimension {
      name     = "CertificateName"
      operator = "Include"
      values   = ["*"]
    }
  }

  description = "The Key Vault certificate has expired."

  action {
    action_groups = [var.action_group_id]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
