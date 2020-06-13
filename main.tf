provider "google" {
  credentials = file("../../credentials.json")
  project = "${var.project_name}"
  region  = "${var.location}"
  zone    = "${var.zone}"
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "default" {
  name         = "vm-${random_id.instance_id.hex}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["http-server"]

  provisioner "remote-exec" {
        connection {
          host    = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
          type    = "ssh"
          user    = "${var.gce_ssh_user}"
          timeout = "500s"
          private_key = "${file("${var.gce_ssh_priv_key_file}")}"
        }
        inline = [
          "sudo firewall-cmd --permanent --add-port=8080/tcp",
          "sudo firewall-cmd --reload",
          "sudo yum -y install git ansible",
          "sudo yum install python-pip -y",
          "sudo pip install python-jenkins",
          "git clone https://github.com/jmpu0186/iac-webinar-devops.git",
		  "sudo ansible-playbook iac-webinar-devops/docker-installation/docker.yml",
		  "sudo chmod 777 /var/run/docker.sock",
		  "sudo ansible-playbook iac-webinar-devops/jenkins-installation/jenkins.yml",
          "sudo ansible-playbook iac-webinar-devops/jenkins-installation/jobs.yml"
        ]

      }
}

resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80","8080","443"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}


output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}