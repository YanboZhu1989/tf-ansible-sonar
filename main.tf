locals {
  network = "default"
  image = "ubuntu-2004-focal-v20221018"
  ssh_user = "ansible"
  private_key_path = "~/.ssh/ansbile_ed25519"
}


provider "google" {
  # Configuration options
  project = "awesome-pilot-367212"
  region = "australia-southeast1-b"
}


resource "google_compute_instance" "sonar-server" {
  name         = "sonar-server"
  machine_type = "e2-micro"
  zone         = "australia-southeast1-b"
  
  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = local.image
    }
  }

  network_interface {
    network = local.network
    access_config {}
  }


  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = google_compute_instance.sonar-server.network_interface.0.access_config.0.nat_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook  -i ${google_compute_instance.sonar-server.network_interface.0.access_config.0.nat_ip}, --private-key ${local.private_key_path} sonar.yaml"
  }
}
