variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = ""
}

variable "managed_nodegroup_instance_type" {
  description = "Managed nodegroup instance type"
  type        = string
  default     = ""
}

variable "managed_nodegroup_min_size" {
  description = "Managed nodegroup minimum type"
  type        = number
  default     = 2
}

variable "eks_version" {
  description = "EKS version"
  type        = string
  default     = "1.24"
}