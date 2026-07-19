# Dockercat Stage 2 — Deployment Explanation

## 1. Introduction

Stage 2 of the Dockercat project combines Terraform and Ansible to automate infrastructure provisioning, server configuration, and application deployment.

The goal is to create an environment comparable to the Stage 1 Vagrant deployment, but instead of running the application on a local virtual machine, the infrastructure is provisioned on AWS using Terraform.

Terraform is responsible for creating the infrastructure required to host the application. Ansible is then used to configure the provisioned server and deploy the Dockerized Dockercat application.

The deployment contains three main application services:

1. React frontend
2. Node.js/Express backend API
3. MongoDB database

The deployment process follows a sequential order because each stage depends on the successful completion of the previous stage.

---

# 2. Execution Order

The overall Stage 2 deployment follows this sequence:

```text
Terraform Initialization
        |
        v
Terraform Infrastructure Provisioning
        |
        v
AWS EC2 Instance Created
        |
        v
Ansible Connection Established
        |
        v
Docker Installation
        |
        v
Application Directory Created
        |
        v
Application Repository Cloned
        |
        v
Docker Images Built
        |
        v
MongoDB Started
        |
        v
Backend Started
        |
        v
Frontend Started
        |
        v
Backend Health Check
        |
        v
Deployment Complete
```

This order is important because Ansible cannot configure or deploy the application until the infrastructure exists and the EC2 instance is reachable.

---

# 3. Terraform's Role

Terraform is responsible for Infrastructure as Code.

It provisions the AWS resources required for the Dockercat application.

The Terraform configuration performs the following tasks:

* Selects the required AWS region.
* Identifies the default VPC.
* Creates an EC2 security group.
* Configures inbound network access.
* Creates the EC2 instance.
* Associates the required SSH key.
* Configures the EC2 instance type.
* Provides the required user data or provisioning commands.
* Invokes Ansible deployment automation.
* Exposes useful outputs after deployment.

The Terraform configuration is divided into several files to maintain good Infrastructure as Code practices.

```text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── .terraform.lock.hcl
└── .gitignore
```

### `variables.tf`

This file defines reusable Terraform variables.

Using variables avoids hard-coding deployment-specific configuration throughout the Terraform configuration.

Examples of configurable values include:

* AWS region
* EC2 instance type
* SSH key name
* SSH private key path
* SSH access IP address
* Application configuration

This allows the same Terraform configuration to be reused in different environments.

### `main.tf`

The `main.tf` file defines the main AWS infrastructure.

It includes the AWS provider configuration, VPC data lookup, security group, and EC2 instance.

The security group provides access to:

* SSH on port 22
* Frontend on port 3000
* Backend API on port 5000

The EC2 instance hosts the Dockerized Dockercat application.

### `outputs.tf`

The outputs file exposes important information after deployment.

The outputs include:

* Public IP address
* EC2 instance ID
* Frontend URL
* Backend URL

This makes it easy to identify the deployed server and access the application.

---

# 4. Ansible's Role

After Terraform provisions the EC2 instance, Ansible is responsible for server configuration and application deployment.

Ansible performs configuration management tasks on the remote Ubuntu server.

The Ansible deployment is organised into roles so that each role has a clear responsibility.

The deployment order is important because Ansible executes tasks sequentially.

The major responsibilities are:

1. Install and configure Docker.
2. Prepare the application environment.
3. Clone the application source code.
4. Build and start the application containers.
5. Verify that the backend API is available.

---

# 5. Docker Role

The Docker role is responsible for preparing the EC2 server to run containers.

The tasks include:

* Updating the APT package cache.
* Installing required packages.
* Installing Docker.
* Installing Docker Compose.
* Ensuring the Docker service is running.
* Adding the Ubuntu user to the Docker group.

The Docker role must run before the application deployment because the application cannot be containerized or started until Docker is available.

The role uses Ansible modules such as:

* `apt`
* `apt_repository`
* `get_url`
* `unarchive`
* `systemd`
* `user`

The exact modules depend on the implementation used by the role.

The role is positioned early in the sequence because all subsequent container operations depend on Docker being installed and running.

---

# 6. Application Role

The application role prepares the directory where the Dockercat application is deployed.

The role creates:

```text
/opt/dockercat
```

It then clones the Dockercat source code from GitHub.

The role also ensures that the application directory has the correct ownership.

The main Ansible modules used include:

* `file` — creates and manages the application directory.
* `git` — clones or updates the application repository.

This role runs after Docker installation because the application will later be built and deployed using Docker.

---

# 7. Container Role

The container role is responsible for starting the Dockercat application.

The role uses Docker Compose to build and start the application services.

The application contains:

```text
Frontend
    |
    v
Backend API
    |
    v
MongoDB
```

The Docker Compose configuration starts:

* Frontend container
* Backend container
* MongoDB container

The container role executes the Docker Compose deployment after Docker has been installed and the application source code has been cloned.

The role uses Ansible modules such as:

* `community.docker.docker_compose_v2`
* `command`
* `shell`

depending on the task implementation.

The purpose of this role is to ensure that all required application services are running together.

---

# 8. Frontend and Backend Configuration

The frontend is a React application served through an Nginx container.

The backend is a Node.js/Express application running on port 5000.

The frontend communicates with the backend through the backend API.

The frontend API endpoint is dynamically constructed using the browser hostname:

```javascript
const API_URL = `${window.location.protocol}//${window.location.hostname}:5000/api/products`;
```

This design avoids hard-coding the EC2 public IP address into the frontend application.

When the application is accessed from the EC2 server, the browser automatically uses the current server hostname and connects to port 5000 for API requests.

This makes the application more portable between environments.

---

# 9. MongoDB and Data Persistence

MongoDB is deployed as a separate Docker service.

The backend communicates with MongoDB using the Docker Compose service name rather than relying on a hard-coded external IP address.

Products submitted through the frontend dashboard are stored in MongoDB.

The data flow is:

```text
User
 |
 v
React Frontend
 |
 v
Node.js/Express API
 |
 v
MongoDB
```

This architecture separates the application services and allows the database to maintain application data independently from the frontend and backend containers.

The application was tested by adding a product through the dashboard and querying the backend API.

The API returned the added product, confirming that the frontend, backend, and database were communicating correctly.

The MongoDB data volume should be retained across container restarts to ensure that products remain available after services are restarted.

---

# 10. Backend Verification

The Ansible deployment includes a backend availability check.

The purpose of this check is to confirm that the backend API has started successfully before the deployment is considered complete.

The API can be tested using:

```bash
curl http://<PUBLIC_IP>:5000/api/products
```

An empty database may initially return:

```text
[]
```

After adding a product, the same endpoint returns the stored product data.

This provides a simple verification that the backend is accessible and connected to the database.

---

# 11. Security Group Configuration

Terraform creates a security group for the EC2 instance.

The security group controls network access to the deployed application.

The required inbound ports are:

| Port | Purpose            |
| ---- | ------------------ |
| 22   | SSH administration |
| 3000 | React frontend     |
| 5000 | Backend API        |

Outbound traffic is allowed so that the server can access required external services such as package repositories and container registries.

SSH access should ideally be restricted to the administrator's public IP address rather than allowing SSH from the entire internet.

---

# 12. Variables and Good Practice

Both Terraform and Ansible use variables to improve reusability.

Terraform variables are used for infrastructure-specific settings such as:

* AWS region
* Instance type
* SSH key
* Administrator IP address

Ansible variables are used for deployment configuration such as:

* Application directory
* Repository URL
* Frontend port
* Backend port
* MongoDB configuration

Centralising configuration in variable files reduces duplication and makes the deployment easier to maintain.

---

# 13. Why the Order Matters

The order of execution is critical because the application has dependencies between its components.

Terraform must run first because the EC2 server does not exist before infrastructure provisioning.

Docker installation must occur before application deployment because Docker is required to build and run the containers.

The application repository must be cloned before Docker Compose can build the application images.

The containers must be started before the backend health check can succeed.

Finally, the backend availability check confirms that the deployment has reached a usable state.

Therefore, the sequence is:

```text
Terraform
   ↓
EC2 Instance
   ↓
Docker
   ↓
Application Source
   ↓
Docker Compose
   ↓
MongoDB
   ↓
Backend
   ↓
Frontend
   ↓
Health Check
```

Each step prepares the environment required by the next step.

---

# 14. Stage 2 Result

The completed Stage 2 deployment demonstrates Infrastructure as Code and configuration management working together.

Terraform provisions the AWS infrastructure.

Ansible configures the server.

Docker provides containerization.

Docker Compose orchestrates the application services.

MongoDB provides persistent application data.

The final deployment provides:

* Automated AWS EC2 provisioning.
* Automated Docker installation.
* Automated application source deployment.
* Automated container image building.
* Automated multi-container deployment.
* React frontend.
* Node.js/Express backend.
* MongoDB database.
* Product management functionality.
* Persistent application data.
* Deployment verification through the backend API.

The deployment therefore satisfies the Stage 2 requirement of combining Terraform for infrastructure provisioning with Ansible for server configuration and application deployment.
