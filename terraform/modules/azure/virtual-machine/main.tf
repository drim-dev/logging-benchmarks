terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}-public-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "network_interface" {
  name                = "${var.name}-network-interface"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  internal_dns_name_label = var.name

  ip_configuration {
    name                          = "${var.name}-network-interface-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "network_interface_security_group_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                  = var.name
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  size                  = "Standard_D4ads_v5"

  os_disk {
    name                 = "${var.name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  computer_name  = var.name
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = var.ssh_public_key
  }

  boot_diagnostics {
    storage_account_uri = var.storage_account_primary_blob_endpoint
  }
}
