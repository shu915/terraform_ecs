resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project}-${var.environment}-logs"
    Project     = var.project
    Environment = var.environment
  }
}