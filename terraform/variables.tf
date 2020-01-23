variable "prefix" {
  default = "aks"
}

variable "suffix" {
  default = "02"
}

variable log_analytics_workspace_name { default = "workspace" }

variable kubernetes_version { default = "1.14.8" }
variable vm_size { default = "Standard_B2s" }
variable log_analytics_workspace_sku { default = "PerGB2018" }

variable node_pool_name { default = "default" }
variable node_count { default = 1 }
variable max_node_count { default = 5 }

variable "location" {
  default = "westus2"
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "service_principal_object_id" { }

variable "public_ssh_key_path" {
  description = "The Path at which your Public SSH Key is located. Defaults to ~/.ssh/id_rsa.pub"
}

variable "network_plugin" { default = "kubenet" }

variable "network_policy" { default = "calico" }

variable "vnet_address_space" { default = "10.0.0.0/16" }
variable "services_subnet_name" { default = "services" }
variable "services_subnet_address_space" { default = "10.0.1.0/24" }

variable "pod_cidr" { default = "10.244.0.0/16" }
variable "service_cidr" { default = "172.17.0.0/16" }
variable "dns_service_ip" { default = "172.17.0.4" }
variable "docker_bridge_cidr" { default = "172.18.0.1/16" }
variable "load_balancer_sku" { default = "standard" }