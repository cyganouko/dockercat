# Docker CAT2 – Containerized E-commerce Platform

## Overview

This project demonstrates the containerization of a full-stack e-commerce application using Docker and Docker Compose. The application consists of three independent services:

* **Frontend:** React application served using Nginx
* **Backend:** Express.js REST API
* **Database:** MongoDB

Docker Compose orchestrates these services, enabling them to communicate over a Docker bridge network while maintaining persistent data storage using Docker volumes.

---

## Prerequisites

Before running the application, install the following software:

* Docker Engine
* Docker Compose
* Git

Install Docker by following the official documentation:

https://docs.docker.com/engine/install/

Verify the installation:

```bash
docker --version
docker compose version
git --version
```

---

## Clone the Repository

```bash
git clone https://github.com/cyganouko/dockercat.git
cd dockercat
```

---

## Running the Application

Build and start all services:

```bash
docker compose up --build
```

Run in detached mode:

```bash
docker compose up --build -d
```

---

## Stopping the Application

```bash
docker compose down
```

To remove containers, networks and the MongoDB volume:

```bash
docker compose down -v
```

---

## Accessing the Application

Once all containers are running, open:

**Frontend**

```
http://localhost:3000
```

**Backend API**

```
http://localhost:5000
```

---

## Running Containers

To confirm that all services are running:

```bash
docker ps
```

Expected containers:

* yolo-frontend
* yolo-backend
* yolo-mongodb

