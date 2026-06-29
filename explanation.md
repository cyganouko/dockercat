# Docker CAT2 – Containerization Explanation

## 📌 Project Overview
This project is a containerized e-commerce web application built using Docker and Docker Compose.  
It consists of three main services:
- Frontend (User interface)
- Backend (API server)
- MongoDB (Database)

The goal was to fully containerize the application, ensure service communication, and enable persistent storage for uploaded products.

---

## 🧱 Choice of Base Images

### Frontend
- `node:18-alpine` (build stage)
- `nginx:alpine` (production stage)

Reason:
- Node is required to build the React/Vite application.
- Nginx is used to serve static files in production.
- Alpine images are lightweight, reducing final image size significantly.

---

### Backend
- `node:18-alpine`

Reason:
- Lightweight and efficient for running Express/Node APIs.
- Reduces container size and improves performance.

---

### Database
- `mongo:6.0`

Reason:
- Official MongoDB image ensures stability and compatibility.
- Preconfigured database environment reduces setup complexity.

---

## 🐳 Dockerfile Design

Each service uses a Dockerfile with the following key directives:

### FROM
Defines the base image for each service.

### WORKDIR
Sets the working directory inside the container.

### COPY
Copies application source code into the container.

### RUN
Installs dependencies using npm.

### EXPOSE
Defines the port the container listens on.

### CMD
Defines the command used to start the application.

---

### Frontend Optimization (Multi-stage build)
- First stage builds the React app using Node.js
- Second stage uses Nginx to serve static files
- This reduces image size significantly

---

## 🌐 Docker Compose Networking

Docker Compose automatically creates a **bridge network** allowing containers to communicate using service names.

### Example:
- Backend connects to MongoDB using:

### Services communication:
- frontend → backend
- backend → mongo

No manual IP configuration is required.

---

## 💾 Volume Configuration (Persistence)

MongoDB uses a Docker volume:

```yaml
volumes:
  mongo_data:
