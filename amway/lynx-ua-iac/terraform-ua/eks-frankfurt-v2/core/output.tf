output "vpc_id" {
  value = module.frankfurt_eks_vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.frankfurt_eks_vpc.vpc_cidr_block
}

output "spot_subnets" {
  value = aws_subnet.spot_workers.*.id
}

output "additional_spot_subnets" {
  value = aws_subnet.ondemand_workers.*.id
}

output "public_subnets" {
  value = module.frankfurt_eks_vpc.public_subnets
}

output "private_subnets" {
  value = module.frankfurt_eks_vpc.private_subnets
}

output "database_subnets" {
  value = module.frankfurt_eks_vpc.database_subnets
}

output "infra_subnets" {
  value = aws_subnet.infra_subnets.*.id
}

output "infra_64_subnets" {
  value = aws_subnet.infra_64_subnets.*.id
}

