# Homelab Nodes Setup

## Overview
Brief description of your homelab and its purpose.

## Node Inventory

| Node Name | Hostname/IP | Role | OS | Hardware Specs | Status |
|-----------|-------------|------|----|---------------|--------|
| k8s-control-plane | 192.168.0.110 | K3s Master | Ubuntu Server 24.04LTS | 3 cores, 4GB RAM, 30GB Storage | Active |
| k-worker1-mini | 192.168.0.200 | K3s Worker | Ubuntu Server 24.04LTS | 4 cores, 8GB RAM, 500GB Storage | Active |
| k-worker2-large | 192.168.0.150 | K3s Worker + DNS | Ubuntu Server 24.04LTS | 4 cores/8 threads, 16GB RAM, 500GB Storage | Active |

## Network Topology
- Diagram or description of how nodes are connected.

## Node Details

### Node 1: [k8s-control-plane]
- **IP Address:** 192.168.0.110
- **Role:** Master Node in K3s cluster
- **Operating System:** Ubuntu Server 24.04LTS
- **Hardware Specs:** 3 core , 4GB RAM , 30GB Storage
- **Services Running:** Kubernetes Control Plane Components
- **Notes:** 

### Node 2: [k-worker1-mini]
- **IP Address:** 192.168.0.200
- **Role:** Worker Node 1
- **Operating System:** Ubuntu Server 24.04LTS
- **Hardware Specs:** 4 cores, 8GB RAM, 500GB Storage
- **Services Running:** Kubernetes Worker Node Components
- **Notes:** 

### Node 3: [k-worker2-large]
- **IP Address:** 192.168.0.150
- **Role:** Worker Node 2
- **Operating System:** Ubuntu Server 24.04LTS
- **Hardware Specs:** 4 cores 8 Threads, 16GB RAM, 500GB Storage
- **Services Running:** Kubernetes Worker Node Components , Bind9DNS
- **Notes:** Running Bind9 using Docker as DNS server. More on the DNS setup: [local-dns-server-setup.md](./local-dns-server-setup.md) 

<!-- Repeat for each node -->

## Setup Steps

### 1. Hardware Setup

#### Control Plane (k8s-control-plane)
- **Platform**: Virtual Machine on Mac using VMware Fusion
- **Host Machine**: MacBook (main work machine)
- **VM Configuration**: 3 cores, 4GB RAM, 30GB storage
- **Network**: Bridged networking for local network access

#### Worker Nodes (k-worker1-mini & k-worker2-large)
- **Platform**: Dedicated physical computers
- **Installation**: Ubuntu Server OS installed directly on hardware
- **Network**: Connected to local network via Ethernet

### 2. OS Installation

#### Control Plane - Ubuntu VM Setup (VMware Fusion)
1. **Create New VM in VMware Fusion**
   - Open VMware Fusion
   - Select "Create a custom virtual machine"
   - Choose "Linux" → "Ubuntu 64-bit"
   
2. **VM Configuration**
   - Allocate 4GB RAM
   - Create 30GB virtual disk
   - Set 3 CPU cores
   - Configure bridged networking
   
3. **Ubuntu Server Installation**
   - Download Ubuntu Server 24.04 LTS ISO
   - Mount ISO to VM and boot
   - Follow standard Ubuntu Server installation
   - Configure static IP: 192.168.0.110
   - Enable SSH access

#### Worker Nodes - Ubuntu Server Installation (Physical Hardware)
1. **Create Bootable USB Drive**
   - Download Ubuntu Server 24.04 LTS ISO
   - Use tools like Rufus (Windows) or `dd` command (Linux/Mac)
   - Create bootable USB drive with Ubuntu Server ISO
   
2. **Physical Installation Process**
   - Boot from USB drive on target hardware
   - Follow Ubuntu Server installation wizard
   - Configure network settings:
     - k-worker1-mini: Static IP 192.168.0.200
     - k-worker2-large: Static IP 192.168.0.150
   - Set up user accounts and SSH access
   - Complete installation and reboot

3. **Post-Installation Configuration**
   - Update system packages: `sudo apt update && sudo apt upgrade`
   - Configure SSH keys for remote access
   - Set static IP addresses in netplan configuration
   - Verify network connectivity

### 3. Network configuration
- Configure static IP addresses for all nodes
- Set up SSH access and key-based authentication
- Configure DNS settings (post DNS server deployment)

### 4. Service deployment
- Install and configure K3s cluster. [k3s-cluster-setup.md](./k3s-cluster-setup.md)
- Deploy additional services (DNS, monitoring, etc.)

### 5. Monitoring setup
- Set up cluster monitoring and logging
- Configure alerting and dashboards

## Maintenance & Updates
- Update schedule
- Backup procedures

## Troubleshooting
- Common issues and solutions

## References
- Links to guides,

*Last Updated: July 20, 2025*