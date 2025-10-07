# Homelab Setup

## Overview

This HomeLab serves as a comprehensive learning and development environment focused on exploring emerging technologies, particularly Kubernetes and container orchestration in an on-premises setting. The infrastructure is designed to provide hands-on experience with modern DevOps practices, cloud-native technologies, and open-source solutions.

### Primary Objectives

**🎯 Technology Exploration & Learning**
- Gain practical experience with Kubernetes cluster management and orchestration
- Explore container technologies, service mesh, and microservices architecture
- Learn infrastructure-as-code principles and GitOps methodologies
- Experiment with monitoring, logging, and observability tools

**🚀 Personal Project Deployment**
- Deploy personal projects using end-to-end automated CI/CD pipelines
- Implement GitOps workflows for application lifecycle management
- Practice blue-green deployments, canary releases, and rollback strategies
- Build scalable, resilient applications using cloud-native patterns

**🔧 Open Source Technology Stack**
- Leverage open-source alternatives to enterprise solutions
- Build cost-effective infrastructure using community-driven tools
- Contribute back to the open-source ecosystem through learning and experimentation
- Evaluate and compare different technology solutions for real-world scenarios

### Infrastructure Philosophy

**Hybrid Architecture**: Combining virtual machines (control plane) with physical hardware (worker nodes) to simulate realistic enterprise environments while maintaining cost efficiency.

**Production-Like Environment**: Implementing proper DNS resolution, ingress controllers, persistent storage, and networking to mirror production deployments.

**Automation-First Approach**: Everything is documented, version-controlled, and automated where possible to ensure reproducibility and maintainability.

**Security & Best Practices**: Following industry standards for security, monitoring, and operational excellence from the ground up.

### Learning Outcomes

This HomeLab environment provides practical experience with:
- **Container Orchestration**: K3s/Kubernetes + Talos Linux cluster management
- **Infrastructure Management**: Physical and virtual server administration
- **Network Engineering**: DNS, ingress, load balancing, and service discovery
- **DevOps Practices**: CI/CD pipelines, GitOps, and automated deployments
- **Monitoring & Observability**: Metrics, logging, and alerting systems
- **Security**: Network policies, RBAC, secrets management, and TLS/SSL

The ultimate goal is to create a production-ready environment that serves as both a learning platform and a deployment target for personal projects, all while maintaining professional standards and best practices.

---

## 📚 Documentation Structure

To keep this HomeLab journey organized and reproducible, the documentation is structured in the **chronological order of setup and experimentation**. Each major component or phase has its own dedicated guide, arranged to reflect the actual sequence in which the environment was built and configured:

1. **[Node Inventory & Hardware Setup](./1.nodes-setup.md)**  
   Details on hardware selection, VM/physical node setup, and initial OS installation.

2. **[K3s Cluster Setup](./2.k3s-cluster-setup.md)**  
   Step-by-step instructions for installing and configuring the Kubernetes (K3s) cluster.

3. **[Local DNS Server Setup](./3.local-dns-server-setup.md)**  
   Guide to deploying and configuring a Bind9 DNS server for internal service discovery.

4. **[Jenkins CI/CD Pipeline Setup](./4.jenkins-setup.md)**  
   Instructions for deploying Jenkins in Kubernetes and integrating automated pipelines.

> **Note:**  
> The documentation files are intentionally ordered to match the real-world progression of the HomeLab setup. This makes it easier to follow along, replicate the environment, or revisit specific phases as the HomeLab evolves.

Each section is self-contained and can be accessed by clicking the links above.  
This modular and sequential approach makes it easy to follow, update, and expand as the HomeLab grows.

---
*Last Updated: Oct 7, 2025*