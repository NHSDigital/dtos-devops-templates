variable "name" {
  description = "The name of the azurerm_monitor_smart_detector_alert_rule."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy Service Health alerts into."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID where the alert will be set."
  type        = string
}

variable "action_group_id" {
  description = "Azure monitor action group ID."
  type        = string
}

variable "frequency" {
  description = "Specifies the frequency of this Smart Detector Alert Rule in ISO8601 duration format (e.g., PT5M, PT15M, PT1H)."
  type        = string
  default     = "PT1M"

  validation {
    condition     = can(regex("^PT([0-9]+H)?([0-9]+M)?([0-9]+S)?$", var.frequency))
    error_message = "Frequency must be a valid ISO8601 duration string starting with 'PT' (e.g., PT5M, PT1H, PT15M, PT30S)."
  }
}

variable "detector_type" {
  description = <<EOT
Specifies the Built-In Smart Detector type that this alert rule will use.

Allowed values:
- FailureAnomaliesDetector
- RequestPerformanceDegradationDetector
- DependencyPerformanceDegradationDetector
- ExceptionVolumeChangedDetector
- TraceSeverityDetector
- MemoryLeakDetector
EOT

  type = string

  validation {
    condition = contains([
      "FailureAnomaliesDetector",
      "RequestPerformanceDegradationDetector",
      "DependencyPerformanceDegradationDetector",
      "ExceptionVolumeChangedDetector",
      "TraceSeverityDetector",
      "MemoryLeakDetector"
    ], var.detector_type)

    error_message = "detector_type must be one of: FailureAnomaliesDetector, RequestPerformanceDegradationDetector, DependencyPerformanceDegradationDetector, ExceptionVolumeChangedDetector, TraceSeverityDetector, or MemoryLeakDetector."
  }
}

variable "severity" {
  description = "Specifies the severity level. Allowed values: Sev0, Sev1, Sev2, Sev3, Sev4."
  type        = string
  default     = "Sev2"

  validation {
    condition     = contains(["Sev0", "Sev1", "Sev2", "Sev3", "Sev4"], var.severity)
    error_message = "Severity must be one of: Sev0, Sev1, Sev2, Sev3, Sev4."
  }
}

variable "description" {
  description = "description of the smart detector alert rule."
  type        = string
}

variable "scope_resource_ids" {
  description = "List of resource IDs the smart detector alert rule applies to."
  type        = list(string)
}
