locals {
  app_private_ip       = "10.0.1.11"
  db_private_ip        = "10.0.1.12"
  telemetry_private_ip = "10.0.1.13"
  k6_private_ip        = "10.0.1.14"
}

resource "azurerm_resource_group" "resource_group" {
  name     = "logging-benchmarks"
  location = "germanywestcentral"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.username}storageaccount"
  location                 = azurerm_resource_group.resource_group.location
  resource_group_name      = azurerm_resource_group.resource_group.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "ssh-public-key"
  location  = azurerm_resource_group.resource_group.location
  parent_id = azurerm_resource_group.resource_group.id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

# App VM

resource "azurerm_network_security_group" "app_network_security_group" {
  name                = "app-network-security-group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "app_virtual_machine" {
  source = "../../modules/azure/virtual-machine"
  providers = {
    azurerm = azurerm
  }

  username                              = var.username
  name                                  = "app"
  resource_group_location               = azurerm_resource_group.resource_group.location
  resource_group_name                   = azurerm_resource_group.resource_group.name
  subnet_id                             = azurerm_subnet.subnet.id
  private_ip                            = local.app_private_ip
  network_security_group_id             = azurerm_network_security_group.app_network_security_group.id
  ssh_public_key                        = azapi_resource_action.ssh_public_key_gen.output.publicKey
  storage_account_primary_blob_endpoint = azurerm_storage_account.storage_account.primary_blob_endpoint
}

# DB VM

resource "azurerm_network_security_group" "db_network_security_group" {
  name                = "db-network-security-group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "db_virtual_machine" {
  source = "../../modules/azure/virtual-machine"
  providers = {
    azurerm = azurerm
  }

  username                              = var.username
  name                                  = "db"
  resource_group_location               = azurerm_resource_group.resource_group.location
  resource_group_name                   = azurerm_resource_group.resource_group.name
  subnet_id                             = azurerm_subnet.subnet.id
  private_ip                            = local.db_private_ip
  network_security_group_id             = azurerm_network_security_group.app_network_security_group.id
  ssh_public_key                        = azapi_resource_action.ssh_public_key_gen.output.publicKey
  storage_account_primary_blob_endpoint = azurerm_storage_account.storage_account.primary_blob_endpoint
}

# Telemetry VM

resource "azurerm_network_security_group" "telemetry_network_security_group" {
  name                = "telemetry-network-security-group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "telemetry_virtual_machine" {
  source = "../../modules/azure/virtual-machine"
  providers = {
    azurerm = azurerm
  }

  username                              = var.username
  name                                  = "telemetry"
  resource_group_location               = azurerm_resource_group.resource_group.location
  resource_group_name                   = azurerm_resource_group.resource_group.name
  subnet_id                             = azurerm_subnet.subnet.id
  private_ip                            = local.telemetry_private_ip
  network_security_group_id             = azurerm_network_security_group.app_network_security_group.id
  ssh_public_key                        = azapi_resource_action.ssh_public_key_gen.output.publicKey
  storage_account_primary_blob_endpoint = azurerm_storage_account.storage_account.primary_blob_endpoint
}

# K6 VM

resource "azurerm_network_security_group" "k6_network_security_group" {
  name                = "k6-network-security-group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "k6_virtual_machine" {
  source = "../../modules/azure/virtual-machine"
  providers = {
    azurerm = azurerm
  }

  username                              = var.username
  name                                  = "k6"
  resource_group_location               = azurerm_resource_group.resource_group.location
  resource_group_name                   = azurerm_resource_group.resource_group.name
  subnet_id                             = azurerm_subnet.subnet.id
  private_ip                            = local.k6_private_ip
  network_security_group_id             = azurerm_network_security_group.app_network_security_group.id
  ssh_public_key                        = azapi_resource_action.ssh_public_key_gen.output.publicKey
  storage_account_primary_blob_endpoint = azurerm_storage_account.storage_account.primary_blob_endpoint
}
