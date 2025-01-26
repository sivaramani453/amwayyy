#### ROLE For CLUSTER ####
data "aws_iam_policy_document" "eks-cluster-role-policy-json" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "eks-cluster-role" {
  name               = "${var.env}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-role-policy-json.json
  tags               = {
    Name = "${var.env}-eks-cluster-role"
  }
}

resource "aws_iam_instance_profile" "eks-cluster-iamrole-instances-profile" {
  name = aws_iam_role.eks-cluster-role.name
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-cnipolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-cluster-role.name
}

#### ROLE For WORKER NODE ####
data "aws_iam_policy_document" "eks-worker-role-policy-json" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "eks-worker-role" {
  name               = "${var.env}-eks-worker-role"
  assume_role_policy = data.aws_iam_policy_document.eks-worker-role-policy-json.json
  tags               = {
    Name = "${var.env}-eks-worker-role"
  }
}

resource "aws_iam_instance_profile" "eks-worker-iamrole-instances-profile" {
  name = aws_iam_role.eks-worker-role.name
  role = aws_iam_role.eks-worker-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-role-nodepolicy" {
  role       = aws_iam_role.eks-worker-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks-worker-role-cnipolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-worker-role.name
}
resource "aws_iam_role_policy_attachment" "eks-worker-role-servicepolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-worker-role.name
}
resource "aws_iam_role_policy_attachment" "eks-worker-role-containerregistry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-worker-role.name
}
resource "aws_iam_role_policy_attachment" "eks-worker-role-AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks-worker-role.name
}
resource "aws_iam_role_policy_attachment" "eks-worker-role-AmazonSSMFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.eks-worker-role.name
}
resource "aws_iam_role_policy_attachment" "eks-worker-role-AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.eks-worker-role.name
}