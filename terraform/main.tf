resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-hybrid-networking-rg"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-vnet-${var.suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = [ var.vnet_address_space ]  
}

resource "azurerm_subnet" "example" {
  name                  = var.services_subnet_name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_name  = azurerm_virtual_network.example.name
  address_prefix        = var.services_subnet_address_space
}

# use this with internal-only cluster
resource "azurerm_subnet" "lb" {
  name                  = "load-balancer"
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_name  = azurerm_virtual_network.example.name
  address_prefix        = "10.0.2.0/24"
}

# monitoring workspace
resource "azurerm_log_analytics_workspace" "example" {
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    sku                 = var.log_analytics_workspace_sku
}

# monitoring solution
resource "azurerm_log_analytics_solution" "example" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.example.location
    resource_group_name   = azurerm_resource_group.example.name
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    workspace_name        = azurerm_log_analytics_workspace.example.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr${var.location}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "${var.prefix}-basic-${var.suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "${var.prefix}-cluster-01"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = var.node_pool_name
    node_count          = var.node_count
    min_count           = var.node_count
    max_count           = var.max_node_count
    enable_auto_scaling = true 
    vm_size             = var.vm_size
    vnet_subnet_id      = azurerm_subnet.example.id
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_policy      = var.network_policy
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    docker_bridge_cidr  = var.docker_bridge_cidr    
    load_balancer_sku   = var.load_balancer_sku
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    oms_agent {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  }
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_subnet.example.id
  role_definition_name = "Network Contributor"
  principal_id         = var.service_principal_object_id
}

# attach acr to aks
resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_resource_group.example.id
  role_definition_name             = "AcrPull"
  principal_id                     = var.client_id
  skip_service_principal_aad_check = true
}