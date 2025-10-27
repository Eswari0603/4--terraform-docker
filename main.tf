terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "docker" {}

# Pull nginx image
resource "docker_image" "nginx_image" {
  name = "nginx:stable"
  keep_locally = true
}

# Create container
resource "docker_container" "nginx" {
  name  = "terraform-nginx-local"
  image = docker_image.nginx_image.image_id   # ✅ fixed line

  ports {
    internal = 80
    external = 8080
  }

  env = [
    "TZ=Asia/Kolkata"
  ]

  restart = "unless-stopped"
}

output "container_id" {
  value = docker_container.nginx.id
}

output "container_name" {
  value = docker_container.nginx.name
}

output "host_port" {
  value = docker_container.nginx.ports[0].external
}

