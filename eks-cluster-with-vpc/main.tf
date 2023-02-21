module "eks_cluster" {
  source = "./modules/eks_with_vpc"
  aws_region = var.aws_region
  cluster_name = var.cluster_name
  managed_nodegroup_instance_type = var.managed_nodegroup_instance_type
  managed_nodegroup_min_size = var.managed_nodegroup_min_size
  eks_version = var.eks_version
  vpc_cidr = var.vpc_cidr
}
