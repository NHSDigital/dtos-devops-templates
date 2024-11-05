variable "storage_account_service" {
  type    = set(string)
  default = ["blobServices", "queueServices", "tableServices", "fileServices"]
}