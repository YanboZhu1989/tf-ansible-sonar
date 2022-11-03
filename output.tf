output "nginx_ips" {
  value = {
    for k, v in google_compute_instance.sonar-server : k => "http://${v.network_interface.0.access_config.0.nat_ip}"
  }
}