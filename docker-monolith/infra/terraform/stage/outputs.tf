output "external_ip_address_app" {
  value = module.docker.*.external_ip_address_app
}
