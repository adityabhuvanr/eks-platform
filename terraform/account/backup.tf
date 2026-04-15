locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "managed-account-backup"
    },
    var.extra_tags
  )
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_backup_vault" "this" {
  name        = var.backup_vault_name
  kms_key_arn = var.kms_key_arn

  tags = local.common_tags
}

resource "aws_backup_vault_lock_configuration" "this" {
  count = var.enable_vault_lock ? 1 : 0

  backup_vault_name   = aws_backup_vault.this.name
  min_retention_days  = var.vault_lock_min_retention_days
  max_retention_days  = var.vault_lock_max_retention_days
}

resource "aws_iam_role" "backup" {
  name = var.backup_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "backup_service" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "this" {
  name = var.backup_plan_name

  rule {
    rule_name                = "${var.environment}-daily-backup"
    target_vault_name        = aws_backup_vault.this.name
    schedule                 = var.schedule_cron
    start_window             = var.start_window
    completion_window        = var.completion_window
    enable_continuous_backup = var.enable_continuous_backup

    lifecycle {
      cold_storage_after = var.cold_storage_after_days
      delete_after       = var.delete_after_days
    }

    recovery_point_tags = local.common_tags
  }

  tags = local.common_tags
}

resource "aws_backup_selection" "tagged_resources" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = var.selection_name
  plan_id      = aws_backup_plan.this.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.resource_tag_key
    value = var.resource_tag_value
  }
}
