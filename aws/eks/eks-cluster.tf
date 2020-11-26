provider "aws" {
  version = ">= 2.28.1"
  region  = var.aws_region
}

locals {
  cluster_name = var.cluster_name
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets      = var.create_new_subnets == "true" ? aws_subnet.public.*.id : var.public_subnets
  cluster_version = var.cluster_version
  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
  }
  cluster_endpoint_private_access	= "true"
  vpc_id = var.create_new_vpc == "true" ? aws_vpc.selected[0].id : var.vpc_id
  map_users = var.map-users-eks
  worker_groups = [
    {
      name = "workers1"
      key_name = var.ssh_key_name
      asg_desired_capacity = 1
      asg_max_size = 8
      asg_min_size = 0
      subnets = var.create_new_subnets == "true" ? [aws_subnet.private[0].id] : [var.private_subnets[0]]
      public_ip = false
      instance_type = var.worker_type
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name = "workers2"
      key_name = var.ssh_key_name
      asg_desired_capacity = 1
      asg_max_size = 8
      asg_min_size = 0
      subnets = var.create_new_subnets == "true" ? [aws_subnet.private[1].id] : [var.private_subnets[1]]
      public_ip = false
      instance_type = var.worker_type
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name = "workers3"
      key_name = var.ssh_key_name
      asg_desired_capacity = 1
      asg_max_size = 8
      asg_min_size = 0
      subnets = var.create_new_subnets == "true" ? [aws_subnet.private[2].id] : [var.private_subnets[2]]
      public_ip = false
      instance_type = var.worker_type
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}