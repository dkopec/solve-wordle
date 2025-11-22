output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.main.name
}

output "container_app_fqdn" {
  description = "Fully qualified domain name of the Container App"
  value       = azurerm_container_app.main.ingress[0].fqdn
}

output "container_app_url" {
  description = "URL of the deployed application"
  value       = "https://${azurerm_container_app.main.ingress[0].fqdn}"
}

output "container_app_environment_name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.main.name
}

output "application_insights_instrumentation_key" {
  description = "Application Insights Instrumentation Key"
  value       = var.enable_application_insights ? azurerm_application_insights.main[0].instrumentation_key : ""
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights Connection String"
  value       = var.enable_application_insights ? azurerm_application_insights.main[0].connection_string : ""
  sensitive   = true
}
