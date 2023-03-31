# AWS EKS Multicluster Observability

## Audience

This repo is a must for anyone who wants to try the AWS provided Observability Accelerator (link #1), with more than one EKS cluster and verify the collected metrics from all the clusters in the dashboards of a common `Amazon Managed Grafana` workspace.


## Repo Organization 

The repo has two folders, each with an unique purpose :
1. `eks-cluster-with-vpc`: A terraform repo that uses upstream EKS blueprints to stand up EKS clusters in their own VPC
2. `observability`: A terraform repo that uses the Observability Accelerator (link #1) to :
    1. Create a `Amazon Managed Service for Prometheus` workspace
    2. Create `Recording` and `Alerting` rules in AMP
    3. Create a data source (based on AMP) and dashboards folder in `Amazon Managed Grafana`
    4. Deploy ADOT to collect metrics from EKS clusters and deployed applications 

Both the folders can be reused multiple times, once for each EKS cluster.

## Prerequisites

Following the instructions found in this [blog post](https://aws.amazon.com/blogs/mt/announcing-aws-observability-accelerator-to-configure-comprehensive-observability-for-amazon-eks/)
1. Create an `Amazon Managed Grafana` workspace, capture the workspace ID (ex: g-abc123)
2. Create an Grafana dashboards API key, capture the key content

## Usage

1. Git clone this project and `cd` into it

   ```sh 
   git clone https://github.com/vchintal/aws-eks-multicluster-observability
   cd aws-eks-multicluster-observability
   ```
2. If your EKS clusters are pre-created, skip to step #4, else change directory into `eks-cluster-with-vpc` and create two `terraform` variable files as shown below. 
   
   **eks-cluster-1.tfvars**
   ```
   vpc_cidr                        = "10.0.0.0/16"
   aws_region                      = "us-west-2"
   cluster_name                    = "eks-cluster-1"
   managed_nodegroup_instance_type = "t3.xlarge"
   managed_nodegroup_min_size      = 2
   eks_version                     = "1.25"
   ``` 
   **eks-cluster-2.tfvars**
   ```
   vpc_cidr                        = "192.168.0.0/16"
   aws_region                      = "us-west-2"
   cluster_name                    = "eks-cluster-2"
   managed_nodegroup_instance_type = "t3.xlarge"
   managed_nodegroup_min_size      = 2
   eks_version                     = "1.25"
   ``` 
3. In two seperate terminal session run the following commands, one in each terminal. The two commands below can be run parallelly.

   ```sh 
   terraform apply -var-file=eks-cluster-1.tfvars -state=./eks-cluster-1.tfstate --auto-approve
   ```

   ```sh 
   terraform apply -var-file=eks-cluster-2.tfvars -state=./eks-cluster-2.tfstate --auto-approve
   ```
4. Now change directory to `observability` and create a `terraform` variable file, specific to the first EKS cluster created, as shown below. Ensure to substitute the `<AMG Workspace ID>` and `<AMG Key with admin access>` with correct values working with the existing `Amazon Managed Grafana` workspace.

   **eks-cluster-1.tfvars**
   ```
   # (mandatory) EKS cluster id/name
   eks_cluster_id = "eks-cluster-1"

   enable_alertmanager         = true
   create_dashboard_folder     = true
   enable_dashboards           = true
   create_grafana_data_source  = true

   enable_recording_rules      = true
   enable_alerting_rules       = true
   enable_java_recording_rules = true
   enable_java_alerting_rules  = true

   # (mandatory) Amazon Managed Grafana Workspace ID: ex: g-abc123
   managed_grafana_workspace_id = "<AMG Workspace ID>"

   # (optional) Leave it empty for a new workspace to be created
   managed_prometheus_workspace_id = ""

   # (mandatory) Grafana API Key - https://docs.aws.amazon.com/grafana/latest/userguide/API_key_console.html
   grafana_api_key = "<AMG Key with admin access>"
   ```
5. Deploy the Observability for the first EKS cluster and capture the `Amazon Managed Service for Prometheus` workspace ID that was created as a result. 

   > **Note!** Run the task to completion before moving to the next step

   ```sh 
   terraform apply -var-file=eks-cluster-1.tfvars -state=./eks-cluster-1.tfstate --auto-approve
   ```
6. Similar to step #4, create a `terraform` variable file, specific to the second EKS cluster created, as shown below. This time around, in addition to `<AMG Workspace ID>` and `<AMG Key with admin access>`, substitute `<ws-XXXX-XXXXX-XXXXX-XXXXXXXXX>` as well with the workspace ID you noted the previous step.

   **eks-cluster-2.tfvars**
   ```
   # (mandatory) EKS cluster id/name
   eks_cluster_id = "eks-cluster-2"

   enable_alertmanager         = false
   create_dashboard_folder     = false
   enable_dashboards           = false
   create_grafana_data_source  = false

   enable_recording_rules      = false
   enable_alerting_rules       = false
   enable_java_recording_rules = false
   enable_java_alerting_rules  = false

   # (mandatory) Amazon Managed Grafana Workspace ID: ex: g-abc123
   managed_grafana_workspace_id = "<AMG Workspace ID>"

   # (optional) Leave it empty for a new workspace to be created
   managed_prometheus_workspace_id = "<ws-XXXX-XXXXX-XXXXX-XXXXXXXXX>"

   # (mandatory) Grafana API Key - https://docs.aws.amazon.com/grafana/latest/userguide/API_key_console.html
    grafana_api_key = "<AMG Key with admin access>"
7. Deploy the Observability for the second EKS cluster 
   ```sh
   terraform apply -var-file=eks-cluster-2.tfvars -state=./eks-cluster-2.tfstate --auto-approve
   ```

## Verifying Multicluster Observability

One you have successfully run the above setup, you should be able to see dashboards similar to the images shown below.

![Sample Image 1](../images/image1.png)

![Sample Image 2](../images/image2.png)

## Links 

1. https://github.com/aws-observability/terraform-aws-observability-accelerator
