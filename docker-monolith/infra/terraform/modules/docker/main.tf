resource "yandex_compute_instance" "app" {
  name = "docker-app"
  count = var.node_count

  labels = {
    tags = "docker-app"
  }

  resources {
    core_fraction = 5
    cores         = 2
    memory        = 1
  }

  boot_disk {
    initialize_params {
      image_id = var.docker_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "docker:${file(var.public_key_path)}"
  }
}
