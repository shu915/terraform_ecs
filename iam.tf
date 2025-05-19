data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_secrets_manager_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_s3_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ses_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

# GitHub Actions用のOIDCプロバイダーを設定
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

data "aws_iam_policy_document" "github_actions_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

# GitHub ActionsからCDできるようにする
resource "aws_iam_role" "github_actions_role" {
  name               = "${var.project}-${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_role_policy.json
}

data "aws_iam_policy_document" "github_actions_permissions_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"] 
  }
}

# ポリシーの作成
resource "aws_iam_policy" "github_actions_permissions" {
  name        = "${var.project}-${var.environment}-github-actions-permissions"
  description = "Permissions for GitHub Actions"
  policy      = data.aws_iam_policy_document.github_actions_permissions_policy.json
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "github_actions_permissions_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_permissions.arn
}
