variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_nodegroup_instance_type" {
  description = "Instance type for the cluster managed node group"
  type        = string
  default     = "t3.small"
}

variable "managed_nodegroup_min_size" {
  description = "Minumum number of instances in the node group"
  type        = number
  default     = 2
}

variable "eks_version" {
  type        = string
  description = "EKS cluster version"
  default     = "1.24"
}
