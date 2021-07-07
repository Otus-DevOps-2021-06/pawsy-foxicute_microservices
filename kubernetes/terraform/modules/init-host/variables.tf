variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable init_disk_image_id {
  description = "Disk image for init node"
  default     = "fd8vmcue7aajpmeo39kk"
}

variable subnet_id {
  description = "Subnets for modules"
}

variable name {
  description = "Instance name"
  default     = "init"
}
