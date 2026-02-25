output "planned_vm_specs" {
  value = {
    for k, v in terraform_data.lab_vm_specs :
    k => v.output
  }
}
