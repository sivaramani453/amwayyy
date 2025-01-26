output "eks_efs_id" {
  value = "${aws_efs_file_system.eks_efs.id}"
}
