terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.83.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "f8dc953a-e967-4e6e-be08-141d9ab31959"
  client_id       = "06e43a4e-cd58-471f-a6a1-80c837262adb"
  client_secret   = "M29xvj~2CPLC.K8nszphshPOiEwhOjB_GK"
  tenant_id       = "77d33cc5-c9b4-4766-95c7-ed5b515e1cce"
}

# Configure Microsoft Azure resource group
resource "azurerm_resource_group" "IaC" {
  name     = "IaC"
  location = "West Europe"
}

# Configure Microsoft Azure virtual network
resource "azurerm_virtual_network" "vNetwork" {
  name                = "IaC-Network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.IaC.location
  resource_group_name = azurerm_resource_group.IaC.name
}

# Configure Microsoft Azure subnet
resource "azurerm_subnet" "IaC-internal" {
  name                 = "IaC-internal"
  resource_group_name  = azurerm_resource_group.IaC.name
  virtual_network_name = azurerm_virtual_network.vNetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Configure Microsoft Azure Public Ip
resource "azurerm_public_ip" "Public-IP" {
  name                = "IaC-Public-IP"
  resource_group_name = azurerm_resource_group.IaC.name
  location            = azurerm_resource_group.IaC.location
  allocation_method   = "Dynamic"
  domain_name_label   = "IaC"
}

# Configure Microsoft Azure network interface
resource "azurerm_network_interface" "Network-Int" {
  name                = "Network-Int"
  location            = azurerm_resource_group.IaC.location
  resource_group_name = azurerm_resource_group.IaC.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.IaC-internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.IaC-Public-IP.id
  }
}

# Configure Microsoft Azure security group
resource "azurerm_network_security_group" "securityGroup" {
  name                = "securityGroup"
  location            = azurerm_resource_group.IaC.location
  resource_group_name = azurerm_resource_group.IaC.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh access"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http access"
    priority                   = 120
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "https access"
    priority                   = 130
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }
}

# Configure Microsoft Azure SSH Key
resource "tls_private_key" "sshKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Configure Microsoft Azure virtual machine
resource "azurerm_linux_virtual_machine" "IaC_Website" {
  name                            = "IaC-Website"
  computer_name                   = "IaC-Website"
  resource_group_name             = azurerm_resource_group.IaC.name
  location                        = azurerm_resource_group.IaC.location
  size                            = "Standard_B1s"
  admin_username                  = "Jenkins"
  disable_password_authentication = False
  network_interface_ids = [
    azurerm_network_interface.Network-Int.id,
  ]

  admin_ssh_key {
    username   = "Jenkins"
    public_key = tls_private_key.sshKey.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "local_file" "keyFile" {
  content         = tls_private_key.sshKey.private_key_pem
  filename        = "/.ssh-key/IaC-Website_key.pem"
  file_permission = "0600"
}

