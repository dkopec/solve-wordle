variable "project_name" {
  description = "Project name derived from repository (automatically set by GitHub Actions)"
  type        = string
  default     = "default"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "container_image" {
  description = "Container image for the application (will be updated by CI/CD)"
  type        = string
  default     = "mcr.microsoft.com/dotnet/samples:aspnetapp"
}

variable "container_cpu" {
  description = "CPU cores for container (0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0)"
  type        = number
  default     = 0.25
}

variable "container_memory" {
  description = "Memory for container in Gi (0.5, 1.0, 1.5, 2.0, 3.0, 4.0)"
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 1
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "production"
}

variable "enable_application_insights" {
  description = "Enable Application Insights for monitoring"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
