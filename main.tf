terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "Projeto-Devops-MinIO-RG"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "Projeto-Devops-MinIO-VNET"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "Projeto-Devops-MinIO-SUBNET"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "Projeto-Devops-MinIO-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "Projeto-Devops-MinIO-VM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Projeto-Devops-MinIO-OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ProjetoDevopsMinIO"
    admin_username = "luan"
    admin_password = "q1w2e3r4"
  }

  #Definindo a forma de acesso.
  os_profile_linux_config {
    #No meu caso coloco true aqui pois a autenticação é por chave ssh
    disable_password_authentication = true

    #No painel do Azure criamos a chave .pem que é a privada.
    #No main.tf precisamos apontar a chave pública .pub dessa privada .pem
    #Comando para gerar a .pub dessa .pem: ssh-keygen -y -f sua-chave.pem > sua-chave.pub
    ssh_keys {
      path     = "/home/luan/.ssh/autorized_keys" #Cria esse caminho dentro da instância onde ficará a chave pública.
      key_data = file("~/azure/acesso-azure.pub") #Caminho para a chave pública na máquina local.
    }
  }
}
