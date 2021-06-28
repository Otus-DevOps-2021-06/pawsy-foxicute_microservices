resource "yandex_vpc_network" "app-network" {
  name = "docker-app-network"
}
resource "yandex_vpc_subnet" "app-subnet" {
  name           = "docker-app-subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.app-network.id}"
  v4_cidr_blocks = [var.v4_blocks]
}
