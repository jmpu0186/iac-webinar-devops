variable "name" {
  default = "cluster-jmpu"
}

variable "project_name" {
  default = "jmpu-gcp"
}

variable "location" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "machine_type" {
  default = "n1-standard-1"  
}

#${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}
variable "gce_ssh_user" {
  default = "gce_ssh"
}

variable "gce_ssh_pub_key_file" {
  default = "keys/id_rsa.pub"
}

variable "gce_ssh_priv_key_file" {
 default = "keys/id_rsa"
}
