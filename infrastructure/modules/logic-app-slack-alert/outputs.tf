output "trigger_callback_url" {
  description = "HTTP trigger callback URL to register with an Azure Monitor action group webhook receiver."
  value       = azurerm_logic_app_trigger_http_request.this.callback_url
  sensitive   = true
}
