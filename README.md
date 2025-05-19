# AWS ECS インフラストラクチャ

このリポジトリは、AWS上でECS（Elastic Container Service）を使用したアプリケーションのインフラストラクチャをTerraformで管理するためのコードベースです。
過去に作成したX cloneをデプロイするために作りました。

## インフラストラクチャの構成

- **ECS**: コンテナ化されたアプリケーションの実行環境
- **RDS**: データベースサーバー
- **SES**: メール送信サービス
- **S3**: オブジェクトストレージ
- **ALB**: アプリケーションロードバランサー
- **Route53**: DNS管理
- **ACM**: SSL証明書管理
- **IAM**: アクセス権限管理
- **VPC**: ネットワーク環境

## 前提条件
- Terraformのバージョンは1.7以上を使用

## 使用方法

1. プロフィール登録
マネージドコンソールでterraformというユーザーを作成し、
アクセスキーとシークレットを、AWS CLIで入力して、作業を開始します


2. Terraformの初期化
```bash
terraform init
```

3. 実行計画の確認
```bash
terraform plan
```

4. インフラストラクチャの作成
```bash
terraform apply
```

5. インフラストラクチャの削除（必要な場合）
```bash
terraform destroy
```

## 変数の設定

`terraform.tfvars`ファイルで以下の変数を設定してください：

- project
- environment
- domain
- aws_account_id
- github_repo
- secret_manager_arn
- db_host

## セキュリティ

- セキュリティグループは最小権限の原則に基づいて設定されています
- GitHub Actionsとの連携にはOIDC認証を使用しています

## 注意事項

- 機密情報はAWS Secrets Managerで管理してください
- 定期的なバックアップの設定を推奨します
