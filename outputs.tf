output "vm_id" {
  description = "ID da máquina virtual"
  value       = azurerm_virtual_machine.vm.id
}

output "private_ip" {
  description = "IP privado da máquina virtual"
  value       = azurerm_network_interface.nic.private_ip_address
}
