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
  default     = 1
}

variable service_account_key_file {
  description = "Account key file"
}

variable cloud_id {
  description = "Cloud ID"
}

variable folder_id {
  description = "Folder ID"
}

variable zone {
  description = "Yandex net zone"
}
