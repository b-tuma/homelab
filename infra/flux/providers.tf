terraform {
    required_version = ">= 0.13.0, < 2.0.0"
    required_providers {
        flux = {
            source = "fluxcd/flux"
            version = "~> 0.8.1"
        }
        github = {
            source = "integrations/github"
            version = "~> 4.19.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.7.1"
        }
        kubectl = {
            source  = "gavinbunney/kubectl"
            version = "~> 1.10.0"
        }
        tls = {
            source  = "hashicorp/tls"
            version = "~> 3.1.0"
        }
    }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

