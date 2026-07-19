# Dockercat — Stage 2

## Terraform + Ansible Infrastructure Automation

Stage 2 extends the Stage 1 Ansible deployment by adding Terraform-based infrastructure provisioning.

The solution provisions an AWS EC2 instance using Terraform and then uses Ansible to configure the server, install Docker, clone the Dockercat application, and deploy the containerized application.

The application consists of:

* React frontend
* Node.js/Express backend API
* MongoDB database

The deployment is automated so that Terraform provisions the infrastructure and Ansible performs the server configuration and application deployment.

---

## Architecture

The Stage 2 deployment follows this sequence:

```text
Developer
    |
    v
Terraform
    |
    v
AWS EC2 Instance
    |
    v
Ansible
    |
    +--> Install Docker
    |
    +--> Clone Dockercat Repository
    |
    +--> Build Docker Images
    |
    +--> Start Containers
    |
    +----------------------+
    |                      |
    v                      v
Frontend                Backend
Port 3000               Port 5000
                            |
                            v
                         MongoDB
                         Port 27017
```

---

## Directory Structure

The Stage 2 implementation is located in the `Stage_two` directory.

```text
Stage_two/
├── README.md
├── explanation.md
├── playbook.yml
├── group_vars/
│   └── all.yml
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── terraform.tfstate
    ├── .terraform.lock.hcl
    └── .gitignore
```

The Terraform state backup file is excluded from version control using `.gitignore`.

---

## Prerequisites

The following tools are required on the deployment machine:

* Terraform
* Ansible
* AWS CLI
* Git
* SSH
* An AWS account with permission to create EC2 resources

The AWS CLI should be configured with valid credentials before running Terraform.

Example:

```bash
aws configure
```

Credentials should never be stored directly inside Terraform source files or committed to GitHub.

---

## Stage 2 Deployment

The Terraform configuration provisions the AWS infrastructure, while Ansible performs the server configuration and application deployment.

### Step 1 — Clone the repository

```bash
git clone https://github.com/cyganouko/dockercat.git
cd dockercat
```

### Step 2 — Switch to the Stage 2 branch

```bash
git checkout Stage_two
```

### Step 3 — Configure Terraform

Navigate to the Terraform directory:

```bash
cd Stage_two/terraform
```

Create a local Terraform variables file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the variables as required:

```bash
nano terraform.tfvars
```

The Terraform variables control deployment-specific configuration such as the AWS region, EC2 instance type, SSH key name, and SSH access configuration.

The `terraform.tfvars` file is excluded from Git using `.gitignore`.

### Step 4 — Initialize Terraform

```bash
terraform init
```

### Step 5 — Format and validate Terraform

```bash
terraform fmt
terraform validate
```

### Step 6 — Review the Terraform plan

```bash
terraform plan
```

The expected plan provisions the EC2 instance and the required security group.

### Step 7 — Apply the Terraform configuration

```bash
terraform apply
```

Confirm the operation by entering:

```text
yes
```

Terraform provisions the EC2 instance and invokes the Ansible deployment process through the configured provisioners.

### Step 8 — Verify the deployment

Terraform displays the deployment outputs after successful completion.

Example:

```text
backend_url = "http://<PUBLIC_IP>:5000"
frontend_url = "http://<PUBLIC_IP>:3000"
instance_id = "<INSTANCE_ID>"
public_ip = "<PUBLIC_IP>"
```

Test the backend API:

```bash
curl http://<PUBLIC_IP>:5000/api/products
```

A successful empty database may initially return:

```text
[]
```

The frontend can be opened in a browser using:

```text
http://<PUBLIC_IP>:3000
```

---

## Application Verification

The application was tested after deployment.

The backend API responds successfully through the public EC2 address:

```bash
curl http://<PUBLIC_IP>:5000/api/products
```

Products can be added through the frontend product-management dashboard.

The frontend uses the current browser hostname to construct the backend API URL:

```javascript
const API_URL = `${window.location.protocol}//${window.location.hostname}:5000/api/products`;
```

This avoids hard-coding the EC2 public IP address into the frontend source code.

The application was successfully tested by adding a product through the dashboard and confirming that the product was returned by the backend API.

---

## Container Verification

The deployed services can be checked on the EC2 instance using:

```bash
docker compose ps
```

The expected services are:

```text
yolo-backend
yolo-frontend
yolo-mongodb
```

The expected exposed ports are:

```text
Frontend: 3000
Backend: 5000
MongoDB: 27017
```

The backend API is available at:

```text
http://<PUBLIC_IP>:5000
```

The frontend is available at:

```text
http://<PUBLIC_IP>:3000
```

---

## Data Persistence

MongoDB is deployed as a separate container and is used as the application's database service.

Products added through the dashboard are stored in MongoDB rather than only in the frontend application container.

The deployment was tested by adding a product through the product-management dashboard and querying:

```bash
curl http://<PUBLIC_IP>:5000/api/products
```

The added product was returned by the API, confirming that the frontend, backend, and database communicate correctly.

MongoDB data persistence should be maintained through the Docker Compose volume configuration so that restarting the application containers does not remove stored product data.

---

## Terraform Outputs

The Terraform configuration exposes useful deployment information through outputs:

* `backend_url` — URL of the backend API
* `frontend_url` — URL of the frontend application
* `instance_id` — AWS EC2 instance ID
* `public_ip` — public IP address of the deployed server

These outputs make it easier to access and verify the deployment after provisioning.

---

## Security Considerations

Sensitive credentials are not stored in the Terraform source code.

The following files are excluded from version control:

```text
terraform.tfvars
terraform.tfstate.backup
.terraform/
```

AWS credentials should be provided through the AWS CLI credential configuration or environment variables.

The Terraform state file contains infrastructure information and must be reviewed carefully before being committed to a public repository.

The EC2 security group permits:

* SSH on port 22 from the configured administrator IP
* Frontend traffic on port 3000
* Backend API traffic on port 5000
* Outbound traffic required by the application

---

## Destroying the Stage 2 Infrastructure

When the deployment is no longer required, the AWS resources can be removed using:

```bash
cd Stage_two/terraform
terraform destroy
```

Confirm the operation by entering:

```text
yes
```

This removes the Terraform-managed AWS resources.

---

## Summary

Stage 2 combines Infrastructure as Code and configuration management.

Terraform is responsible for provisioning the AWS infrastructure, while Ansible configures the provisioned server and deploys the Dockerized application.

The final architecture provides:

* Automated AWS infrastructure provisioning
* Automated server configuration
* Docker container installation
* Automated application deployment
* React frontend
* Node.js/Express backend
* MongoDB database
* Product management functionality
* Persistent product data
* Terraform outputs for deployment access
* Git-based source control
