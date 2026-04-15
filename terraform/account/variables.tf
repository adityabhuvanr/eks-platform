variable "project_name" {
  description = "Project or platform name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "backup_vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for backup vault encryption"
  type        = string
  default     = null
}

variable "enable_vault_lock" {
  description = "Whether to enable backup vault lock"
  type        = bool
  default     = false
}

variable "vault_lock_min_retention_days" {
  description = "Minimum retention days for vault lock"
  type        = number
  default     = 7
}

variable "vault_lock_max_retention_days" {
  description = "Maximum retention days for vault lock"
  type        = number
  default     = 3650
}

variable "backup_plan_name" {
  description = "Backup plan name"
  type        = string
}

variable "schedule_cron" {
  description = "Backup schedule in cron format"
  type        = string
  default     = "cron(0 18 * * ? *)"
}

variable "start_window" {
  description = "Start window in minutes"
  type        = number
  default     = 60
}

variable "completion_window" {
  description = "Completion window in minutes"
  type        = number
  default     = 180
}

variable "delete_after_days" {
  description = "Retention period in days"
  type        = number
  default     = 35
}

variable "cold_storage_after_days" {
  description = "Transition to cold storage after N days"
  type        = number
  default     = 0
}

variable "enable_continuous_backup" {
  description = "Enable PITR/continuous backup where supported"
  type        = bool
  default     = true
}

variable "backup_role_name" {
  description = "IAM role name for AWS Backup"
  type        = string
  default     = "aws-backup-service-role"
}

variable "selection_name" {
  description = "Backup selection name"
  type        = string
  default     = "tag-based-backup-selection"
}

variable "resource_tag_key" {
  description = "Tag key used for backup selection"
  type        = string
  default     = "Backup"
}

variable "resource_tag_value" {
  description = "Tag value used for backup selection"
  type        = string
  default     = "true"
}

variable "extra_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
