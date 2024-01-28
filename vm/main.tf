provider "azurerm" {
    features{}
}

resource "azurerm_resource_group" "jenkins_rg" {
  name     = "jenkins-rg"
  location = "Central India"
}

resource "azurerm_virtual_network" "jenkins_vnet" {
  name                = "jenkins-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.jenkins_rg.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
}

resource "azurerm_subnet" "jenkins_subnet" {
  name                 = "jenkins-subnet"
  resource_group_name  = azurerm_resource_group.jenkins_rg.name
  virtual_network_name = azurerm_virtual_network.jenkins_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "jenkins_public_ip" {
  name                = "jenkins-public-ip"
  location            = azurerm_resource_group.jenkins_rg.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
  allocation_method  = "Dynamic"
}

resource "azurerm_network_security_group" "jenkins_nsg" {
  name                = "jenkins-nsg"
  location            = azurerm_resource_group.jenkins_rg.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
}

resource "azurerm_network_security_rule" "jenkins_allow_http" {
  name                        = "jenkins-allow-http"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jenkins_rg.name
  network_security_group_name = azurerm_network_security_group.jenkins_nsg.name
}

resource "azurerm_network_security_rule" "jenkins_allow_http_alt" {
  name                        = "jenkins-allow-http-alt"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jenkins_rg.name
  network_security_group_name = azurerm_network_security_group.jenkins_nsg.name
}

resource "azurerm_network_interface" "jenkins_nic" {
  name                = "jenkins-nic"
  location            = azurerm_resource_group.jenkins_rg.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name

  ip_configuration {
    name                          = "jenkins-ip"
    subnet_id                     = azurerm_subnet.jenkins_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                  = "jenkins-vm"
  location              = azurerm_resource_group.jenkins_rg.location
  resource_group_name   = azurerm_resource_group.jenkins_rg.name
  network_interface_ids = [azurerm_network_interface.jenkins_nic.id]
  size                  = "Standard_DS1_v2"

  admin_username = "jenkinsadmin"
  admin_password = "JenkinsP@ssw0rd!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
