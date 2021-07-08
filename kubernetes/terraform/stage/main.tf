terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

#module "vpc" {
#
#}
module "init" {
  source          = "../modules/init-host"
  count           = 1
  name            = "init-node-${count.index + 10}"
  public_key_path = var.public_key_path
  subnet_id       = var.subnet_id
}

module "master" {
  source          = "../modules/master-hosts"
  count           = 1
  name            = "master-node-${count.index + 10}"
  public_key_path = var.public_key_path
  subnet_id       = var.subnet_id
}

module "worker" {
  source          = "../modules/worker-hosts"
  count           = 2
  name            = "worker-node-${count.index + 10}"
  public_key_path = var.public_key_path
  subnet_id       = var.subnet_id
}
