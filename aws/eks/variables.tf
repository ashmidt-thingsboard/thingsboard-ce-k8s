/*
Copyright 2019 The KubeOne Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

variable "cluster_name" {
  description = "Name of the cluster"
}

variable "env" {
  default     = "dev"
  description = "Type of env of the cluster"
}

# AWS specific settings

variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS region to speak to"
}

variable "worker_type" {
  default     = "t3.medium"
  description = "instance type for workers"
}

variable "cluster_version" {
  default     = "1.17"
  description = "version of k8s cluster"
}

variable "ssh_key_name" {
  default = []
  description = "Name of the ssh key pair for access to the worker nodes"
}

variable "map-users-eks" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]
}

# VPC settings

variable "vpc_id" {
  default     = "default"
  description = "VPC to use ('default' for default VPC)"
}

variable "public_cidr_subnets" {
  default     = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  description = "CIDR block for public subnets"
}

variable "private_cidr_subnets" {
  default     = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]
  description = "CIDR block for private subnets"
}

variable "create_new_vpc" {
  default     = false
  description = "if you want to create new vpc - set to true"
}

variable "create_new_subnets" {
  default     = false
  description = "if you want to create new subntes - set tot true"
}

variable "private_subnets" {
  default = []
  description = "private subnets of created vpc"
}

variable "public_subnets" {
  default = []
  description = "public subnets of created vpc"
}