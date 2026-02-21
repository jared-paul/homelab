output "vms" {
  description = "VM connection details"
  value = {
    for name, vm in var.vms : name => {
      ip          = vm.ip_address
      ssh_command = "ssh ${var.username}@${vm.ip_address}"
    }
  }
}
