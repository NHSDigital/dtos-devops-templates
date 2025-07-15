output "id" {
  description = "The ID of the container app job."
  value       = azurerm_container_app_job.this.id
}

output "image" {
  description = "The image used by the container app job."
  value       = azurerm_container_app_job.this.template[0].container[0].image
}
