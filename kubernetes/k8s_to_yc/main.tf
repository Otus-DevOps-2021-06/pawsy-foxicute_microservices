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

resource "yandex_kubernetes_cluster" "cluster" {
  name        = "reddit-cluster-1"
  description = "cluster"
  network_policy_provider = "CALICO"

  network_id = var.network_id

  master {
    version = "1.19"
    zonal {
      zone      = var.zone
      subnet_id = var.subnet_id
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = true
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.node_service_account_id
  release_channel = "RAPID"
}
