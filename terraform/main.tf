locals {
  vm_specs = {
    gh_runner = {
      name = "gh-runner-01"
      role = "github-runner"
    }
    podman_app = {
      name = "podman-app-01"
      role = "podman-deploy"
    }
  }
}

# Placeholder resource to keep early planning local/offline.
# Replace with real vsphere_virtual_machine resources once vSphere details are available.
resource "terraform_data" "lab_vm_specs" {
  for_each = local.vm_specs

  input = {
    lab_name   = var.lab_name
    vm_name    = each.value.name
    vm_role    = each.value.role
    cpu        = var.vm_cpu
    memory_mb  = var.vm_memory_mb
    disk_gb    = var.vm_disk_gb
    deploy_now = var.deploy_enabled
  }
}
