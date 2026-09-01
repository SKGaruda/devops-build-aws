# DevOps Build -- End-to-End AWS CI/CD Project

[![Application Running](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/APPLICATION-RUNNING-JENKINS-DEV-PIPELINE-BUILD.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/APPLICATION-RUNNING-JENKINS-DEV-PIPELINE-BUILD.jpg)

## 📌 Project Overview

This project demonstrates an end-to-end DevOps CI/CD implementation for a containerized ReactJS e-commerce web application (**OnlineShop**).

The application is containerized using Docker, with images stored in Docker Hub. Jenkins — hosted on an AWS EC2 instance — automates the CI/CD workflow: source checkout, Docker image build, container testing, Docker Hub publishing, and deployment back to the same EC2 instance.

The project uses **GitHub `dev` and `master` branches** to separate development and production pipelines in Jenkins. Open-source **Uptime Kuma** monitors application availability via HTTP health checks.

> **Status note:** The DEV pipeline is fully built, deployed, and evidenced end to end below. The `master`/PROD pipeline is configured in Jenkins and has run successfully (see the multibranch overview), but there's no captured evidence yet of a distinct PROD image being pushed to Docker Hub or a PROD-tagged container running separately from DEV — the container currently serving port 80 on EC2 is running the `dev-9` tag. Treat PROD as "pipeline built, deployment not yet separately verified."

### Application Repository

GitHub Repository:

https://github.com/SKGaruda/devops-build-aws

### Docker Hub Repository (Verified)

DEV:

https://hub.docker.com/repository/docker/suryakb/devops-build-dev

---

## 🎯 Project Objectives

- Containerize the ReactJS application using Docker.
- Implement GitHub `dev` and `master` branch workflows.
- Configure Jenkins for automated CI/CD on an AWS EC2 host.
- Build and test Docker images automatically.
- Push DEV images to Docker Hub.
- Deploy the application to an AWS EC2 instance.
- Expose the application through HTTP port 80.
- Implement application availability monitoring using Uptime Kuma.
- Verify the master/PROD pipeline runs successfully in Jenkins.

---

## 🏗️ Architecture

```
                    Developer
                        |
                        v
                 git push (dev branch)
                        |
                        v
                    GitHub
                        |
                        v
                 Jenkins on EC2
                        |
                        v
                  DEV Pipeline
                        |
          +-------------+-------------+
          |             |             |
          v             v             v
   Docker Build   Container Test   Push to Docker Hub
                                        |
                                        v
                                 suryakb/devops-build-dev
                                        |
                                        v
                                  Deploy to EC2
                                        |
                                        v
                              Docker Container :80
                                        |
                                        v
                                  ReactJS App
                                        |
                                        v
                                   End Users

Monitoring:
ReactJS Application
        |
        v
   Uptime Kuma
        |
  HTTP Health Check
        |
    UP / DOWN
```

---

## 🛠️ Technology Stack

| Category           | Technology              |
| ------------------- | ------------------------- |
| Application          | ReactJS Web Application    |
| Source Control        | Git / GitHub                |
| Cloud Platform          | AWS                           |
| Compute                  | Amazon EC2 (t2.micro)          |
| Containerization           | Docker                           |
| Container Registry           | Docker Hub                         |
| CI/CD                          | Jenkins (multibranch pipeline)       |
| Webhook                          | GitHub Webhook                         |
| Application Server                 | Nginx                                    |
| Operating System                     | Amazon Linux 2023                          |
| Monitoring                             | Uptime Kuma                                  |
| Protocol                                 | HTTP                                           |
| Application Port                           | 80                                                |

---

# 🔄 End-to-End DevOps Workflow

## Phase 1 -- Local Application Validation

The Docker image was tested locally before pushing to Docker Hub, first by building and running it directly:

[![App Running Locally on 8080](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/APPLICATION-RUNNING-8080-DOCKER-DEV.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/APPLICATION-RUNNING-8080-DOCKER-DEV.jpg)

Then verified again after pulling the image straight from Docker Hub and running it locally:

[![App Running from Docker Hub Image Locally](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/APPLICATION-RUNNING-DOCKERHUB-LOCALLY.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/APPLICATION-RUNNING-DOCKERHUB-LOCALLY.jpg)

---

## Phase 2 -- AWS EC2 Build Server

An EC2 instance (`devops-build-server`, Amazon Linux 2023, t2.micro) was provisioned to host Jenkins and run the deployed application container.

[![EC2 Instance Created](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/EC2-CREATED-DEVOPS-BUILD-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/EC2-CREATED-DEVOPS-BUILD-SERVER.jpg)

---

# ⚙️ Jenkins CI/CD

## Phase 3 -- Multibranch Pipeline

Jenkins is configured as a multibranch pipeline against the GitHub repository, tracking both the `dev` and `master` branches. Both have run and succeeded:

[![Jenkins Multibranch Pipeline — dev and master](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/JENKINS-DEV-PROD-PIPELINE.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/JENKINS-DEV-PROD-PIPELINE.jpg)

The `dev` branch pipeline stages — Checkout, Build Docker Image, Test Container, Push DEV Image, Deploy — all completed successfully:

[![Jenkins DEV Pipeline Stage View](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/JENKINS-DEV-PIPELINE-BUILT-SUCCESS.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/JENKINS-DEV-PIPELINE-BUILT-SUCCESS.jpg)

The `master` branch pipeline (build #2) has also completed successfully in Jenkins, but no separate PROD deployment artifact or running container has been captured yet — see the status note above.

---

## Phase 4 -- Docker Hub (DEV)

The DEV pipeline publishes build-numbered image tags to Docker Hub:

```
suryakb/devops-build-dev:dev-9
```

[![Docker Hub DEV Tag](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2.jpg)

---

# ☁️ AWS EC2 Deployment

## Phase 5 -- Pulling and Running the Image on EC2

Jenkins deploys by pulling the newly published image directly onto the EC2 host:

```bash
docker pull suryakb/devops-build-dev:dev
```

[![Docker Image Pulled on EC2](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/DOCKER-IMAGE-PULLED-EC2-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/DOCKER-IMAGE-PULLED-EC2-SERVER.jpg)

The container was confirmed running on EC2, mapped to port 80:

[![Container Running on EC2](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2-1.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2-1.jpg)

```
IMAGE: suryakb/devops-build-dev:dev-9
PORTS: 0.0.0.0:80->80/tcp
STATUS: Up
```

---

## Phase 6 -- Application Verified Live

The application was confirmed reachable over the public EC2 IP:

[![Application Live on EC2](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/SITE-URL-DEPLOYED-FROM-EC2-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/SITE-URL-DEPLOYED-FROM-EC2-SERVER.jpg)

---

# 📊 Monitoring with Uptime Kuma

## Phase 7 -- Availability Monitoring

Uptime Kuma runs on the EC2 instance (port 3001) and performs HTTP health checks against the application every 60 seconds.

[![Uptime Kuma Dashboard](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/MONITORING-TOOL-EC2-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/MONITORING-TOOL-EC2-SERVER.jpg)

```
Monitor: DevOps Build Application
Status: 🟢 UP
Uptime (24h / 30d / 1yr): 100%
```

---

# 🔐 Security & Credentials Practices Followed

- Docker Hub credentials stored in Jenkins Credentials and injected via `withCredentials`, not hardcoded in the Jenkinsfile.
- Docker login performed using `--password-stdin` rather than passing the password as a CLI argument.
- Application traffic served over port 80; administrative access (SSH, Jenkins, Uptime Kuma) intended to be restricted to the administrator's IP — **security group screenshot not yet captured, so this is stated per project design rather than evidenced here.**

---

# 🧰 Useful Commands

## Docker
```bash
docker ps
docker logs devops-build-app
docker pull suryakb/devops-build-dev:latest
docker restart devops-build-app
```

## Jenkins
```bash
sudo systemctl status jenkins
sudo systemctl restart jenkins
sudo journalctl -u jenkins -f
```

---

# 📸 Project Evidence

### 1. Local Docker Test (port 8080)
[![Local 8080](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/APPLICATION-RUNNING-8080-DOCKER-DEV.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/APPLICATION-RUNNING-8080-DOCKER-DEV.jpg)

### 2. Docker Hub Image Verified Locally
[![Docker Hub Local](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/APPLICATION-RUNNING-DOCKERHUB-LOCALLY.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/APPLICATION-RUNNING-DOCKERHUB-LOCALLY.jpg)

### 3. EC2 Instance Created
[![EC2 Created](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/EC2-CREATED-DEVOPS-BUILD-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/EC2-CREATED-DEVOPS-BUILD-SERVER.jpg)

### 4. Jenkins Multibranch Overview (dev + master)
[![Jenkins Multibranch](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/JENKINS-DEV-PROD-PIPELINE.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/JENKINS-DEV-PROD-PIPELINE.jpg)

### 5. Jenkins DEV Pipeline — Stage View
[![DEV Stage View](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/JENKINS-DEV-PIPELINE-BUILT-SUCCESS.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/JENKINS-DEV-PIPELINE-BUILT-SUCCESS.jpg)

### 6. Docker Hub DEV Tag
[![Docker Hub Tag](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2.jpg)

### 7. Image Pulled on EC2
[![Image Pulled](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/DOCKER-IMAGE-PULLED-EC2-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/DOCKER-IMAGE-PULLED-EC2-SERVER.jpg)

### 8. Container Running on EC2
[![Container Running](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2-1.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/LATEST-DEV-DOCKER-IMAGE-JENKINS-EC2-1.jpg)

### 9. Application Live via EC2 Public IP
[![Live App](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/SITE-URL-DEPLOYED-FROM-EC2-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/SITE-URL-DEPLOYED-FROM-EC2-SERVER.jpg)

### 10. Uptime Kuma Monitoring
[![Uptime Kuma](https://github.com/SKGaruda/devops-build-aws/raw/main/screenshots/MONITORING-TOOL-EC2-SERVER.jpg)](/SKGaruda/devops-build-aws/blob/main/screenshots/MONITORING-TOOL-EC2-SERVER.jpg)

*(GitHub repository view and EC2 security group screenshots are not yet captured — add them here if you want the evidence set complete.)*

---

# 📈 Key Project Outcomes

```
GitHub (dev branch)
   ↓
GitHub Webhook
   ↓
Jenkins
   ↓
Docker Build
   ↓
Container Test
   ↓
Docker Hub (DEV)
   ↓
AWS EC2
   ↓
Docker Container (:80)
   ↓
ReactJS Application
   ↓
Uptime Kuma Monitoring
```

The DEV pipeline successfully published and deployed:

```
suryakb/devops-build-dev:dev-9
```

The application was verified running and monitored on the public EC2 endpoint. The `master` branch pipeline is configured and has run successfully in Jenkins; a distinct PROD image/deployment has not yet been separately verified.

---

# 🎯 Key DevOps Concepts Demonstrated

- Git branching strategy (`dev` / `master`)
- Jenkins Multibranch Pipeline
- Jenkinsfile-driven CI/CD
- Docker containerization and image versioning
- Docker Hub as image registry
- AWS EC2 deployment
- Nginx-served ReactJS build
- Secure Jenkins credentials handling
- Application uptime monitoring
- Troubleshooting and root cause analysis

---

# 🧹 Cleanup / Cost Control

```bash
docker stop devops-build-app uptime-kuma
docker rm devops-build-app uptime-kuma
docker images
docker rmi <IMAGE_ID>
sudo systemctl stop jenkins
sudo systemctl disable jenkins
```

Terminate the EC2 instance from the AWS Console once the project is no longer needed, and confirm no other billable resources (EBS volumes, Elastic IPs, Load Balancers) remain. Docker Hub repositories can be retained as portfolio evidence.

---

# 🏆 Project Status

| Component               | Status                              |
| ------------------------ | ------------------------------------ |
| ReactJS Application        | ✅ Working                             |
| `dev` Branch Pipeline         | ✅ Successful                            |
| `master` Branch Pipeline         | ✅ Runs successfully in Jenkins            |
| Docker Hub DEV                      | ✅ Verified                                  |
| Docker Hub PROD                        | ⚠️ Not separately evidenced                    |
| EC2 Deployment                            | ✅ Successful (running `dev-9` tag)               |
| Application Port 80                          | ✅ Accessible                                       |
| Uptime Kuma                                     | ✅ Running, reporting UP                               |
| Security Group Evidence                            | ⚠️ Not yet captured                                       |
| Project Documentation                                 | ✅ Completed                                                |

---

## ⭐ Architecture Summary

**GitHub → Jenkins → Docker → Docker Hub (DEV) → AWS EC2 → Docker Container → ReactJS Application → Uptime Kuma**

This project demonstrates a working CI/CD pipeline for the DEV workflow end to end, with the PROD workflow built and passing in Jenkins but pending separate deployment verification.
