data "azurerm_storage_container" "license_container" {
  count                = !var.existing_helix_core && var.blob_container != "" ? 1 : 0
  name                 = var.blob_container
  storage_account_name = var.blob_account_name
}

resource "azurerm_role_assignment" "storage_read_role" {
  count                = !var.existing_helix_core && var.blob_container != "" ? 1 : 0
  scope                = data.azurerm_storage_container.license_container[0].resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_virtual_machine.helix_core[0].identity[0].principal_id
}

data "azurerm_kubernetes_cluster" "perforce_cluster" {
  count               = var.existing_aks_cluster_name != "" ? 1 : 0
  name                = var.existing_aks_cluster_name
  resource_group_name = var.existing_aks_cluster_resource_group
}

resource "azurerm_role_assignment" "aks_role" {
  count                = var.existing_aks_cluster_name != "" ? 1 : 0
  scope                = data.azurerm_kubernetes_cluster.perforce_cluster[0].id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_linux_virtual_machine.driver.identity[0].principal_id
}

data "azurerm_subscription" "subscription_data" {
}

resource "azurerm_role_assignment" "subscription_read_role_client_vms" {
  count = length(azurerm_linux_virtual_machine.locustclients)

  scope                = data.azurerm_subscription.subscription_data.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.locustclients[count.index].identity[0].principal_id
}
