resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.project}-${var.environment}-ecr"

  image_scanning_configuration {
    scan_on_push = true
  }
}