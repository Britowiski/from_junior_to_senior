# 🚀 Infra as Code & Config Management: Terraform + Ansible on AWS

This repository documents an evolution in my DevOps journey. The primary goal of this project is to apply the **Separation of Concerns** principle: **Terraform** is used exclusively to provision the cloud infrastructure, while **Ansible** handles the operating system configuration and application deployment.

Instead of relying on complex Bash scripts within the `user_data` block, the EC2 instance is provisioned completely clean and secure. Ansible then takes control via SSH to install Docker, configure the environment, and spin up an Apache web server (`httpd`).

---

## 🏗️ Project Architecture

The AWS infrastructure provisioned includes an isolated network, internet routing, and strict firewall rules.

```text
[ LOCAL MACHINE ]
        | 1. Runs Terraform
        v
+-----------------------------+
| AWS CLOUD (us-east-1)       |
| -> Creates VPC (10.0.0.0/16)|
| -> Creates Public Subnet    |
| -> Opens Ports 80 and 22    |
| -> Injects SSH Key into EC2 |
+-----------------------------+
        | 2. Terraform outputs the Public IP
        v
[ LOCAL MACHINE ]
        | 3. Runs Ansible Playbook via SSH (Port 22)
        v
+-----------------------------+
| EC2 INSTANCE (Ubuntu 22.04) |
| -> Installs Docker & Compose|
| -> Creates docker-compose   |
| -> Spins up Container       |
+-----------------------------+
        | 4. Web Traffic (Port 80)
[ USER'S BROWSER ] -> "It works!"