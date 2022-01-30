terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}
locals {
  token = "token"
  cloud_id = "cloud_id"
  folder_id = "folder_id"
  bucket = "bucket"
  service_account_id = "service_accound_ip"
  ssh_path = "~/.ssh/ssh_name.pub"
}

provider "yandex" {
  token     = local.token
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "proxy" {
  name = "proxy"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qqvji2rs2lehr7d1l"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(local.ssh_path)}"
  }
}

resource "yandex_dataproc_cluster" "dataproc" {
  name = "dataproc-cluster"
  labels = {
    created_by = "terraform"
  }
  bucket = local.bucket
  service_account_id = local.service_account_id
  ui_proxy = true
  zone_id = "ru-central1-a"

  cluster_config {
    version_id = "2.0"
    hadoop {
      services = ["HDFS", "LIVY", "MAPREDUCE", "SPARK", "TEZ", "YARN"]
      ssh_public_keys = [file(local.ssh_path)]
    }

    subcluster_spec {
      name = "master"
      role = "MASTERNODE"
      resources {
        resource_preset_id = "s2.small"
        disk_size = 128
        disk_type_id = "network-ssd"
      }
      subnet_id = yandex_vpc_subnet.subnet.id
      hosts_count = 1
    }

    subcluster_spec {
      name = "data"
      role = "DATANODE"
      resources {
        resource_preset_id = "s2.small"
        disk_type_id       = "network-hdd"
        disk_size          = 128
      }
      subnet_id   = yandex_vpc_subnet.subnet.id
      hosts_count = 1
    }

    subcluster_spec {
      name = "compute"
      role = "COMPUTENODE"
      resources {
        resource_preset_id = "s2.small"
        disk_type_id       = "network-hdd"
        disk_size          = 128
      }
      subnet_id   = yandex_vpc_subnet.subnet.id
      hosts_count = 1
    }
  }
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

output "public_address_proxy" {
  value = yandex_compute_instance.proxy.network_interface.0.nat_ip_address
}
