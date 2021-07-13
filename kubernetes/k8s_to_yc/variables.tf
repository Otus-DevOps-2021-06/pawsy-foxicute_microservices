variable "service_account_key_file" {
  description = "key.json"
}

variable "cloud_id" {
  description = "Cloud"
}

variable "folder_id" {
  description = "Folder"
}

variable "zone" {
  description = "Zone"
  default     = "ru-central1-b"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "service_account_id" {

}

variable "subnet_id" {

}

variable "network_id" {

}

variable "node_service_account_id" {

}
