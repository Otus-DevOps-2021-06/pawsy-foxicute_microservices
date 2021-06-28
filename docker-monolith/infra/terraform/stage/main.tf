provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "vpc" {
  source    = "../modules/vpc"
  v4_blocks = var.in_v4_blocks
}

module "docker" {
  source          = "../modules/docker"
  int_db_address  = module.db.internal_ip_address_db
  public_key_path = var.public_key_path
  app_disk_image  = var.app_disk_image
  subnet_id       = var.subnet_id
  node_count      = 2;
}