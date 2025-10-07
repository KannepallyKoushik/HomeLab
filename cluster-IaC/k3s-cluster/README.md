# K3s Kubernetes Cluster Setup

## Overview

This guide documents the setup of a lightweight Kubernetes cluster using [K3s](https://k3s.io/) for HomeLab experimentation and learning.  
**Currently, the cluster has been set up manually**—nodes were provisioned and configured by hand, following the process below.

---

## ⚡️ Current State

- **Manual Setup:**  
  All nodes (control plane and workers) were installed and configured manually, without using Infrastructure as Code (IaC) tools.
- **Direct OS Installation:**  
  Ubuntu Server was installed directly on physical hardware or VMs, and K3s was installed using the official script.
- **Cluster Management:**  
  All cluster join and configuration steps were performed via shell commands as described below.

---

## 🚀 Future Plans

- **Proxmox Virtualization:**  
  All nodes will be reconfigured to run Proxmox, enabling flexible VM management.
- **Infrastructure as Code:**  
  The K3s cluster will be rebuilt using Terraform/OpenTofu to automate VM provisioning, and Ansible to automate K3s installation and configuration.
- **Automated, Repeatable Deployments:**  
  This will allow for fully reproducible, version-controlled cluster setups.

---

## Manual Installation Steps (Current Setup)

### 1. Prepare Nodes
- **Update OS packages:**
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
- **Configure static IPs:**  
  Edit `/etc/netplan/*.yaml` or use your network manager to assign a static IP to each node.
- **Disable swap (required by Kubernetes):**
  ```bash
  sudo swapoff -a
  sudo sed -i '/ swap / s/^/#/' /etc/fstab
  ```
- **(Optional) Set up SSH keys for passwordless access between nodes.**

---

### 2. Install K3s Server (Control Plane)
- **On the control plane node (e.g., `k8s-control-plane`):**
  ```bash
  curl -sfL https://get.k3s.io | sh -
  ```
- **Check K3s service status:**
  ```bash
  sudo systemctl status k3s
  ```
- **Retrieve the cluster join token:**
  ```bash
  sudo cat /var/lib/rancher/k3s/server/node-token
  ```
- **Get the control plane node's IP address (needed for agents to join):**
  ```bash
  hostname -I
  ```

---

### 3. Install K3s Agents (Worker Nodes)
- **On each worker node:**
  ```bash
  curl -sfL https://get.k3s.io | K3S_URL=https://<CONTROL_PLANE_IP>:6443 K3S_TOKEN=<NODE_TOKEN> sh -
  ```
  Replace `<CONTROL_PLANE_IP>` with your control plane node's IP and `<NODE_TOKEN>` with the token from the previous step.

- **Check K3s agent service status:**
  ```bash
  sudo systemctl status k3s-agent
  ```

---

### 4. Verify Cluster Status
- **On the control plane node:**
  ```bash
  sudo kubectl get nodes
  ```
  All nodes (control plane and workers) should show `STATUS = Ready`.

- **Test kubectl connectivity:**
  ```bash
  sudo kubectl get pods -A
  ```

---

## Post-Installation

- **Deploy sample workloads:**
  ```bash
  sudo kubectl create deployment nginx --image=nginx
  sudo kubectl expose deployment nginx --port=80 --type=NodePort
  ```
- **Set up storage:**  
  K3s comes with [local-path provisioner](https://github.com/rancher/local-path-provisioner) by default for dynamic storage.  
  For advanced setups, consider NFS, Longhorn, or other CSI drivers.
- **Configure networking:**  
  K3s includes Traefik as the default ingress controller (can be disabled or replaced).  
  For bare-metal load balancing, consider [MetalLB](https://metallb.universe.tf/).
- **Enable monitoring/logging:**  
  Deploy Prometheus, Grafana, or other monitoring stacks as needed.

---

## Maintenance & Updates

- **Upgrade K3s:**
  ```bash
  curl -sfL https://get.k3s.io | sh -
  ```
  Run this on each node to upgrade in place.

- **Backup/restore steps:**  
  - Backup etcd (if using embedded etcd) or `/var/lib/rancher/k3s/server/db/` directory.
  - Restore by stopping K3s, replacing the data directory, and restarting the service.

---

## Troubleshooting

- **Check node status:**
  ```bash
  sudo kubectl get nodes
  ```
- **Check K3s logs:**
  ```bash
  sudo journalctl -u k3s -f
  ```
- **Common issues:**
  - **Nodes not joining:** Check token, IP, and firewall settings.
  - **Pods stuck in Pending:** Check node resources and taints.
  - **Network issues:** Ensure ports 6443 (API), 8472 (VXLAN), and 10250 (kubelet) are open.

---

## References

- [K3s Official Quick Start](https://docs.k3s.io/quick-start)
- [K3s Documentation](https://docs.k3s.io/)
- [K3s Local Path Provisioner](https://github.com/rancher/local-path-provisioner)
- [MetalLB Load Balancer](https://metallb.universe.tf/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---
*Last Updated: Oct 7, 2025*