resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-${var.environment}-sg-alb"
  description = "${var.project}-${var.environment}-sg-alb"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-alb"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "alb_sg_in_http" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP from anywhere"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_in_https" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS from anywhere"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "app_sg" {
  name        = "${var.project}-${var.environment}-sg-app"
  description = "${var.project}-${var.environment}-sg-app"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-app"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "app_sg_in_http" {
  security_group_id        = aws_security_group.app_sg.id
  description              = "Allow HTTP from ALB"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group" "db_sg" {
  name        = "${var.project}-${var.environment}-sg-db"
  description = "${var.project}-${var.environment}-sg-db"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-db"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "db_sg_in_postgres" {
  security_group_id        = aws_security_group.db_sg.id
  description              = "Allow Postgres from App"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
}