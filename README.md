# 🧱 Task 4: Infrastructure as Code (IaC) with Terraform

## 🎯 Objective
The goal of this task is to **provision a local Docker container automatically using Terraform**.  
Instead of manually pulling and running a Docker container, Terraform allows us to define the entire process as **Infrastructure as Code (IaC)** — meaning the setup, configuration, and destruction of infrastructure are fully automated.

---

## 🧰 Tools Used
|              Tool         |               Purpose                                         |
|---------------------------|---------------------------------------------------------------|
| **Terraform**             | To automate infrastructure creation and management            |
| **Docker**                | To run lightweight containers locally                         |
| **GitHub**                | To store and share project files                              |
| **Ubuntu (EC2 instance)** | Environment used to execute Terraform and Docker commands     |

---

## 🪜 Step-by-Step Implementation

### 🔹 Step 1: Install Docker
Before using Terraform, Docker must be installed and running.

bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker 

✅ Verification:

sudo docker ps


If Docker is running correctly, it will show a blank table (no error).

🔹 Step 2: Install Terraform

If Terraform is not already installed:

sudo apt update && sudo apt install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
unzip terraform_1.9.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -version


✅ Expected Output:

Terraform v1.9.5

🔹 Step 3: Create a Project Folder
mkdir tf-docker-local
cd tf-docker-local


This folder will contain your Terraform configuration files.

🔹 Step 4: Create main.tf

This file contains all Terraform code needed to create the Docker container.

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

# Step 1: Pull nginx image
resource "docker_image" "nginx_image" {
  name         = "nginx:stable"
  keep_locally = true
}

# Step 2: Create a container from nginx image
resource "docker_container" "nginx" {
  name  = "terraform-nginx-local"
  image = docker_image.nginx_image.image_id

  ports {
    internal = 80
    external = 8080
  }

  env = [
    "TZ=Asia/Kolkata"
  ]

  restart = "unless-stopped"
}

# Step 3: Output container information
output "container_id" {
  value = docker_container.nginx.id
}

output "container_name" {
  value = docker_container.nginx.name
}

output "host_port" {
  value = docker_container.nginx.ports[0].external
}

🔹 Step 5: Initialize Terraform
terraform init


✅ Output Explanation:

Downloads the required Docker provider (kreuzwerker/docker).

Prepares the working directory for Terraform operations.

Example:

Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!

🔹 Step 6: Validate Terraform Code
terraform validate


✅ Purpose: Checks for syntax or configuration errors in the .tf files.

Example output:

Success! The configuration is valid.

🔹 Step 7: Plan the Infrastructure
terraform plan


✅ Purpose: Shows what Terraform will create before actually applying changes.

Example output:

Terraform will perform the following actions:
  + docker_image.nginx_image
  + docker_container.nginx
Plan: 2 to add, 0 to change, 0 to destroy.

🔹 Step 8: Apply the Configuration
terraform apply


Type yes when prompted.

✅ Terraform creates:

Docker Image: nginx:stable

Docker Container: terraform-nginx-local running on port 8080

Example output:

docker_image.nginx_image: Creating...
docker_image.nginx_image: Creation complete
docker_container.nginx: Creating...
docker_container.nginx: Creation complete
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

🔹 Step 9: Verify Docker Container

Check the running containers:

sudo docker ps


✅ Example Output:

CONTAINER ID   IMAGE          COMMAND                  STATUS         PORTS                  NAMES
abcd1234efgh   nginx:stable   "nginx -g 'daemon off;'" Up 1 minute   0.0.0.0:8080->80/tcp   terraform-nginx-local


Now open your browser (or use curl):

http://localhost:8080


✅ You should see the Nginx welcome page.

🔹 Step 10: Check Terraform State
terraform state list


✅ Shows:

docker_image.nginx_image
docker_container.nginx


These are the resources Terraform currently manages.

To view details:

terraform state show docker_container.nginx

🔹 Step 11: Destroy Infrastructure

When you’re done testing:

terraform destroy


Type yes when prompted.

✅ Output:

Destroy complete! Resources: 2 destroyed.


Terraform automatically stops and removes the Docker container and image.
