/* resource "azurerm_public_ip" "pub_ip" {
  name                = "${var.name}-pub_ip"
  location            = var.region
  resource_group_name = var.rg
  allocation_method   = "Dynamic"
} */
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.region
  resource_group_name = var.rg

  ip_configuration {
    name                          = "${var.name}-nic"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.pub_ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.region
  resource_group_name = var.rg

  security_rule {
    name                       = "SSH"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "IPERF"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "IPERF3"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5201"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ICMP"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "instance" {
  name                  = "${var.name}-srv"
  location              = var.region
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.instance_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.name}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.name
    admin_username = "ubuntu"
    admin_password = "Password1234!"
    custom_data    = var.cloud_init_data
  }
  os_profile_linux_config {
    disable_password_authentication = false

    

  }
}
