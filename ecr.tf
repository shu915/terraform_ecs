resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.project}-${var.environment}-ecr"
}