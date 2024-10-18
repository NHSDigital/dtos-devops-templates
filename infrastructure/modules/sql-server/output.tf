
output "sql_server_id" {
  description = "The ID of the SQL Server."
  value       = azurerm_mssql_server.azure_sql_server.id
}
