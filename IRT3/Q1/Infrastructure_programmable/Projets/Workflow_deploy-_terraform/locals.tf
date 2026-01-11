locals {
  common_tags = {
    Company     = var.company_name
    Project     = var.project
    Environment = var.environment
  }
  naming_prefix = "${var.project}-${var.environment}"
}
