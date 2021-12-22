variable "kubeconfig_path" {
  type    = string
  default = "/home/user/.kube/config" 
}

# GitHub Settings

variable "github_owner" {
    type        = string
    description = "GitHub owner"
    default     = "b-tuma"
}

variable "github_token" {
    type        = string
    description = "GitHub token"
    sensitive   = true
}

variable "repository_name" {
    type        = string
    description = "GitHub repository name"
    default     = "homelab"
}

variable "repository_visibility" {
    type        = string
    description = "GitHub repository visibility"
    default     = "public"
}

variable "branch" {
    type        = string
    description = "Repository branch name"
    default     = "main"
}

variable "target_path" {
    type        = string
    description = "Sync target path"
    default     = "./k8s/clusters/nookium"
}