terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "docker" {
  # For local Docker daemon the defaults are fine (connects to DOCKER_HOST or local socket)
  # If you need to set DOCKER_HOST, DOCKER_CERT_PATH, DOCKER_TLS_VERIFY, export them in shell.
}

# Pull the image (remote) so Terraform can ensure latest exists
resource "docker_image" "nginx_image" {
  name = "nginx:stable"   # image name:tag
  keep_locally = true
}

# Create a container from the image
resource "docker_container" "nginx" {
  name  = "terraform-nginx-local"
  image = docker_image.nginx_image.latest

  # Expose and publish ports: map host 8080 -> container 80
  ports {
    internal = 80
    external = 8080
  }

  # Example environment variable
  env = [
    "TZ=Asia/Kolkata"
  ]

  # Optional: restart policy
  restart = "unless-stopped"

  # Wait until container is healthy (if it has healthcheck)
  # If not used, terraform still ensures container exists.
  #healthcheck {
  #  test = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
  #  interval = "10s"
  #  timeout  = "2s"
  #  retries  = 3
  #}

  # Simple command / override if you want (commented)
  #command = ["nginx", "-g", "daemon off;"]
}

# Optional: output the container ID and the mapped port
output "container_id" {
  value = docker_container.nginx.id
}

output "container_name" {
  value = docker_container.nginx.name
}

output "host_port" {
  value = docker_container.nginx.ports[0].external
}

