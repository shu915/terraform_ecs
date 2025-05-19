resource "aws_db_parameter_group" "postgres_parameter_group" {
  name        = "${var.project}-${var.environment}-postgres-pg"
  family      = "postgres17"
  description = "${var.project}-${var.environment}-postgres-parameter-group"

  parameter {
    name  = "client_encoding"
    value = "UTF8"
  }

  parameter {
    name  = "timezone"
    value = "Asia/Tokyo"
  }
}
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "${var.project}-${var.environment}-postgres-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1c.id]
}

#DB情報はシークレットから取得して使う
data "aws_secretsmanager_secret" "db_secret" {
  arn = var.secret_manager_arn
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  db_secrets = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
}



resource "aws_db_instance" "postgres_instance" {
  identifier = "${var.project}-${var.environment}-postgres"
  engine            = "postgres"
  engine_version    = "17"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  username          = local.db_secrets.DB_USER
  password          = local.db_secrets.DB_PASSWORD
  db_name = local.db_secrets.DB_NAME

  parameter_group_name = aws_db_parameter_group.postgres_parameter_group.name
  db_subnet_group_name = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot = true

  # バックアップ関連
  backup_retention_period = 7                        # バックアップを7日間保持
  backup_window           = "03:00-05:00"            # バックアップ時間帯（UTC）
  
  # メンテナンス
  maintenance_window      = "Mon:00:00-Mon:03:00"    # メンテナンス時間帯（UTC）
  
  # 自動マイナーバージョンアップグレード
  auto_minor_version_upgrade = true                  # マイナーバージョンの自動アップグレード
  
  # 削除保護（本番環境向け）
  deletion_protection     = true                      # 誤削除防止
  
  # パフォーマンスインサイト（必要に応じて）
  performance_insights_enabled = true                 # パフォーマンスインサイトの有効化
  performance_insights_retention_period = 7           # 7日間のデータ保持
  
  # 暗号化（推奨）
  storage_encrypted       = true                      # ディスクの暗号化
  
  # マルチAZ設定（高可用性、必要に応じて）
  multi_az                = false                     # 開発環境ではfalse、本番ではtrueが推奨

  tags = {
    Name = "${var.project}-${var.environment}-postgres"
    Project = var.project
    Environment = var.environment
  }
}
