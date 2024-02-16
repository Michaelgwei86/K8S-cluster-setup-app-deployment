resource "aws_iam_role" "effulgencetech-dev-cluster-role" {
  name = "effulgencetech-dev-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "effulgencetech-dev-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.effulgencetech-dev-cluster-role.name
}

resource "aws_eks_cluster" "effulgencetech-dev-cluster" {
  name     = "effulgencetech-dev-cluster"
  role_arn = aws_iam_role.effulgencetech-dev-cluster-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.effulgencetech-dev-private-subnet-1.id,
      aws_subnet.effulgencetech-dev-private-subnet-2.id,
      aws_subnet.effulgencetech-dev-public-subnet-1.id,
      aws_subnet.effulgencetech-dev-public-subnet-2.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.effulgencetech-dev-AmazonEKSClusterPolicy]
}