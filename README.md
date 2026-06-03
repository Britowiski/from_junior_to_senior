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

📂 Directory Structure
providers.tf: Defines the AWS provider and required Terraform version.

variables.tf: Centralizes variables (e.g., default region us-east-1).

data.tf: Dynamically fetches the latest Ubuntu AMI from AWS.

main.tf: Provisions the networking layer (VPC, IGW, Subnet, Route Table), Security Groups, and the EC2 instance with the injected SSH key.

outputs.tf: Outputs the public IP of the provisioned server to the console.

playbook.yml: The Ansible playbook that installs dependencies and runs the Docker container.

hosts.ini: The Ansible inventory file defining the target hosts.

.gitignore: Protects sensitive files (.tfstate, .terraform/) from being pushed to the repository.

🛠️ Tech Stack
Terraform: Declarative infrastructure provisioning.

Ansible: Idempotent configuration management via SSH.

AWS: Cloud provider (EC2, VPC, Security Groups).

Docker & Docker Compose: Application containerization.

Apache HTTP Server: Web server hosting the test page.

🚀 How to Run this Project
1. Prerequisites
Terraform installed on your local machine.

Ansible installed.

AWS CLI configured with your credentials (aws configure).

An SSH key pair generated locally at ~/.ssh/chave_ansible.

2. Provisioning the Infrastructure (Terraform)
Initialize the directory, review the execution plan, and apply it:

Bash
terraform init
terraform plan
terraform apply
Make sure to copy the Public IP address displayed in the outputs at the end.

3. Configuring the Server (Ansible)
Update the hosts.ini file with the copied IP address. Then, run the Playbook to configure the server:

Bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbook.yml
4. Testing the Application
Open your web browser and access the server's IP address on port 80:

Plaintext
http://<YOUR_PUBLIC_IP>
You should see the default Apache "It works!" page.

🧹 Tear Down
To avoid unexpected charges on your AWS account, make sure to destroy the resources after testing:

Bash
terraform destroy
(Confirm by typing yes when prompted)