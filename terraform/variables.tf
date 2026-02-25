variable "deploy_enabled" {
  description = "When false, no vSphere resources are created (safe for offline planning)."
  type        = bool
  default     = false
}

variable "lab_name" {
  description = "Prefix for lab resources"
  type        = string
  default     = "openclaw-lab"
}

variable "vm_cpu" {
  type    = number
  default = 2
}

variable "vm_memory_mb" {
  type    = number
  default = 2048
}

variable "vm_disk_gb" {
  type    = number
  default = 50
}
