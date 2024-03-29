provider "aws" {
  region = local.region
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

locals {
  region               = var.aws_region
  eks_cluster_endpoint = data.aws_eks_cluster.this.endpoint
  create_new_workspace = var.managed_prometheus_workspace_id == "" ? true : false
  tags = {
    Source = "github.com/aws-observability/terraform-aws-observability-accelerator"
  }
}

provider "grafana" {
  url  = module.aws_observability_accelerator.managed_grafana_workspace_endpoint
  auth = var.grafana_api_key
}

# Once the pending PR to the upstream https://github.com/aws-observability/terraform-aws-observability-accelerator
# goes thru, replace the source link below to upstream link
module "aws_observability_accelerator" {
  source = "github.com/vchintal/terraform-aws-observability-accelerator"

  aws_region = var.aws_region

  # creates a new Amazon Managed Prometheus workspace, defaults to true
  enable_managed_prometheus = local.create_new_workspace

  # reusing existing Amazon Managed Prometheus if specified
  managed_prometheus_workspace_id     = var.managed_prometheus_workspace_id
  managed_prometheus_workspace_region = null # defaults to the current region, useful for cross region scenarios (same account)

  # sets up the Amazon Managed Prometheus alert manager at the workspace level
  enable_alertmanager = var.enable_alertmanager

  # decide whether to create a dashboard folder
  create_dashboard_folder = var.create_dashboard_folder

  # decide whether to create/set Amazon Managed service for Prometheus as a datasource
  create_grafana_data_source = var.create_grafana_data_source

  # reusing existing Amazon Managed Grafana workspace
  managed_grafana_workspace_id = var.managed_grafana_workspace_id
  grafana_api_key              = var.grafana_api_key

  tags = local.tags

}

# Once the pending PR to the upstream https://github.com/aws-observability/terraform-aws-observability-accelerator
# goes thru, replace the source link below to upstream link
module "eks_monitoring" {
  source = "github.com/vchintal/terraform-aws-observability-accelerator//modules/eks-monitoring"

  eks_cluster_id = var.eks_cluster_id

  # deploys AWS Distro for OpenTelemetry operator into the cluster
  enable_amazon_eks_adot = true

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = true

  enable_java = true
  java_config = {
    enable_alerting_rules  = var.enable_java_alerting_rules
    enable_recording_rules = var.enable_java_recording_rules
    scrape_sample_limit    = 1
  }
  enable_dashboards      = var.enable_dashboards
  enable_alerting_rules  = var.enable_alerting_rules
  enable_recording_rules = var.enable_recording_rules

  dashboards_folder_id            = module.aws_observability_accelerator.grafana_dashboards_folder_id
  managed_prometheus_workspace_id = module.aws_observability_accelerator.managed_prometheus_workspace_id

  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region

  # optional, defaults to 60s interval and 15s timeout
  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
    scrape_sample_limit    = 2000
  }

  tags = local.tags

  depends_on = [
    module.aws_observability_accelerator
  ]
}
