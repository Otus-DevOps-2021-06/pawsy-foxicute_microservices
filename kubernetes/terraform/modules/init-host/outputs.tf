output "external_ip_address_init" {
  value = yandex_compute_instance.init.network_interface.0.nat_ip_address
}
