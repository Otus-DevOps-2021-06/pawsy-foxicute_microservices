variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable docker_disk_image {
  description = "Disk image for reddit app"
  default = "docker-base"
}

variable subnet_id {
  description = "Subnets for modules"
}

variable node_count {
  description = "Count of instances"
}

variable int_db_address {
  description = "Internal db ip address"
}
