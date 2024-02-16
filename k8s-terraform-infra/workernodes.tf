resource "aws_iam_role" "effulgencetech-dev-worker-nodes" {
  name = "effulgencetech-dev-worker-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "effulgencetech-dev-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.effulgencetech-dev-worker-nodes.name
}

resource "aws_iam_role_policy_attachment" "effulgencetech-dev-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.effulgencetech-dev-worker-nodes.name
}

resource "aws_iam_role_policy_attachment" "effulgencetech-dev-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.effulgencetech-dev-worker-nodes.name
}

resource "aws_eks_node_group" "effulgencetech-dev-worker-nodes" {
  cluster_name    = aws_eks_cluster.effulgencetech-dev-cluster.name
  node_group_name = "effulgencetech-dev-worker-nodes"
  node_role_arn   = aws_iam_role.effulgencetech-dev-worker-nodes.arn

  subnet_ids = [
    aws_subnet.effulgencetech-dev-private-subnet-1.id,
    aws_subnet.effulgencetech-dev-private-subnet-2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.effulgencetech-dev-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.effulgencetech-dev-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.effulgencetech-dev-AmazonEC2ContainerRegistryReadOnly,
  ]
}

