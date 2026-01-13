resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}



resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}
/*
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}
*/


resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.github.arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" ="repo:Wowmind/full-deployment-setup-aws:*"
        }
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#IAM Policy EKS+ECR  + Secret Manager 
resource "aws_iam_policy" "github_ci_policy" {
  name = "github-ci-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ECR (build & push)
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      },

      # EKS (update kubeconfig)
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
} 

resource "aws_iam_role_policy_attachment" "github_ci_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_ci_policy.arn
}

resource "aws_secretsmanager_secret" "xiii" {
  name = "xiii/eks"
}

resource "aws_secretsmanager_secret_version" "xiii" {
  secret_id = aws_secretsmanager_secret.xiii.id
  secret_string = jsonencode({
    EKS_CLUSTER = "eks-prod-1234"
  })
}

# Note: Specific secret permission is handled by `aws_iam_role_policy.allow_secret_cii_eks` (exact ARN).
# If the secret or OIDC provider already exist outside Terraform, import them into state before applying:
# terraform import aws_secretsmanager_secret.cii arn:aws:secretsmanager:us-east-1:182889640030:secret:cii/eks-HwxIMq
# terraform import aws_iam_openid_connect_provider.github arn:aws:iam::182889640030:oidc-provider/token.actions.githubusercontent.com

resource "aws_iam_role_policy" "allow_secret_xiii_eks" {
  name = "AllowSecrets_XII_EKS"
  role = aws_iam_role.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret"]
      Resource = "arn:aws:secretsmanager:us-east-1:182889640030:secret:xiii/eks-HwxIMq"
    }]
  })
}