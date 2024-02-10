provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "k8s_rg" {
  name     = "k8s_rg"
  location = "Central India"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "argo_cluster"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  dns_prefix          = "argocluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  tags = {
    environment = "argocd"
    managed_by  = "Terraform"
  }
}

/* resource "helm_release" "argo_cd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
} */
