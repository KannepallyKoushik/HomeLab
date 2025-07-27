# Jenkins Setup on Kubernetes

This document outlines the setup of Jenkins server deployed on a Kubernetes cluster as part of the HomeLab infrastructure.

## Overview

Jenkins has been successfully deployed on the K3s cluster using Kubernetes manifests. The deployment includes proper namespace isolation, persistent storage, and ingress configuration for local network access.

## Documentation Reference

The deployment follows the official Jenkins documentation for Kubernetes installation:
- **Source**: [Jenkins on Kubernetes - Official Documentation](https://www.jenkins.io/doc/book/installing/kubernetes/)

## Repository Structure

The Jenkins Kubernetes manifests are located under:
```
tools/kubernetes-jenkins/
├── deployment.yaml        # Jenkins deployment configuration
├── jenkins-ingress.yaml   # Ingress service for local access
├── namespace.yaml         # Dedicated namespace for DevOps tools
├── service.yaml          # Jenkins service (NodePort)
├── serviceAccount.yaml    # Service account with appropriate permissions
├── volume.yaml           # Persistent volume for Jenkins data
└── README.md             # Original repository documentation
```

## Setup Process

### 1. Repository Integration
- Cloned the official `kubernetes-jenkins` repository from the Jenkins documentation
- Added as a subrepository to the main HomeLab repository under `tools/kubernetes-jenkins`
- This ensures version control and easy updates while maintaining the original repository structure

### 2. Kubernetes Deployment
The deployment consists of the following components:

#### Namespace
- **Name**: `devops-tools`
- **Purpose**: Isolates Jenkins and related DevOps tools from other cluster workloads

#### Jenkins Deployment
- **Type**: Kubernetes Deployment
- **Namespace**: `devops-tools`
- **Storage**: Persistent Volume for data persistence
- **Service Account**: Dedicated service account with cluster permissions

#### Service Configuration
- **Type**: NodePort (original configuration)
- **Port**: 8080 (Jenkins web interface)
- **Purpose**: Exposes Jenkins within the cluster

### 3. Ingress Configuration

#### Custom Ingress Setup
Since the original deployment used NodePort service and direct cluster access was needed from the local network, a custom ingress configuration was created:

**File**: `jenkins-ingress.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: devops-tools
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
    - host: jenkins.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: jenkins-service
                port:
                  number: 8080
```

#### Access Configuration
- **Hostname**: `jenkins.local`
- **Ingress Controller**: Traefik (configured on the K3s cluster)
- **Access Method**: Local network access via hostname resolution

## Access Information

### Local Network Access
1. **URL**: http://jenkins.local
2. **Requirements**: 
   - Add `jenkins.local` to your local machine's `/etc/hosts` file pointing to the cluster ingress IP
   - Ensure Traefik ingress controller is properly configured on the K3s cluster

### Initial Setup
After deployment, Jenkins will require initial setup:
1. Retrieve the initial admin password from the Jenkins pod
2. Complete the setup wizard
3. Install recommended plugins
4. Create admin user

## Deployment Commands

To deploy Jenkins to the cluster:

```bash
# Navigate to the manifest directory
cd tools/kubernetes-jenkins

# Apply all manifests
kubectl apply -f namespace.yaml
kubectl apply -f serviceAccount.yaml
kubectl apply -f volume.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f jenkins-ingress.yaml
```

## Status and Monitoring

Check deployment status:
```bash
# Check pods in devops-tools namespace
kubectl get pods -n devops-tools

# Check services
kubectl get svc -n devops-tools

# Check ingress
kubectl get ingress -n devops-tools

# View Jenkins logs
kubectl logs -f deployment/jenkins -n devops-tools
```

## Notes

- The deployment uses persistent storage to ensure Jenkins data survives pod restarts (Note: The persistant storage is created in k-worker1-mini node)
- Ingress configuration allows for clean local network access without port forwarding
- Service account provides necessary permissions for Jenkins to interact with the Kubernetes cluster
- The setup is production-ready with proper namespace isolation and resource management

## Jenkins Agents Setup

### Distributed Build Configuration

Jenkins has been configured with worker nodes to enable distributed builds across the local network infrastructure.

#### Worker Node: k-worker2-large

**Hardware Specifications:**
- **CPU**: 4 cores / 8 threads
- **RAM**: 16GB
- **Node Type**: Permanent Agent
- **Executors**: 1
- **Remote Root Directory**: `/var/jenkins/`
- **Labels**: `worker2`

#### Setup Process

1. **Create Node in Jenkins Dashboard**
   - Navigate to Jenkins Dashboard → Manage Jenkins → Manage Nodes and Clouds
   - Click "New Node"
   - Configure node settings:
     - **Node name**: k-worker2-large
     - **Type**: Permanent Agent
     - **Description**: Hardware configuration (4cpu/8 threads, 16gb ram)
     - **Number of executors**: 1 (default)
     - **Remote root directory**: `/var/jenkins/`
     - **Labels**: `worker2`
     - **Usage**: Use this node as much as possible (default)
     - **Launch method**: Launch agent by connecting it to the controller (default)
     - **Availability**: Keep this agent online as much as possible (default)

2. **Agent Installation on Worker Node (k-worker2-large)**

   ```bash
   # Download the Jenkins agent JAR file
   curl -sO http://jenkins.local/jnlpJars/agent.jar
   
   # Create secret file with the node secret from Jenkins
   # (Secret string is provided in Jenkins node configuration page)
   echo "YOUR_SECRET_STRING" > /var/jenkins/secret-file
   ```

3. **Systemd Service Configuration**
   
   Created a systemd service to automatically manage the Jenkins agent:
   
   ```bash
   # Create systemd service file
   sudo tee /etc/systemd/system/jenkins-agent.service << EOF
   [Unit]
   Description=Jenkins Agent
   After=network.target
   
   [Service]
   Type=simple
   User=jenkins
   WorkingDirectory=/opt/jenkins-agent
   ExecStart=/usr/bin/java -jar /opt/jenkins-agent/agent.jar \
        -url http://jenkins.local/ \
        -secret @secret-file -name "k-worker2-large" -webSocket \
        -workDir "/var/jenkins"
   Restart=always
   RestartSec=10
   
   [Install]
   WantedBy=multi-user.target
   EOF
   
   # Enable and start the service
   sudo systemctl daemon-reload
   sudo systemctl enable jenkins-agent
   sudo systemctl start jenkins-agent
   ```

4. **Verification**
   - Check service status: `sudo systemctl status jenkins-agent`
   - Verify node connection in Jenkins Dashboard → Manage Nodes
   - Node should appear as "Connected" with the `worker2` label

#### Benefits of Distributed Setup

- **Load Distribution**: Build jobs can be distributed across multiple machines
- **Resource Isolation**: Heavy builds run on dedicated worker nodes
- **Scalability**: Additional worker nodes can be easily added to increase build capacity
- **High Availability**: Controller remains available even if worker nodes are offline

#### Worker Node Management

```bash
# Check agent status
sudo systemctl status jenkins-agent

# Restart agent
sudo systemctl restart jenkins-agent

# View agent logs
sudo journalctl -u jenkins-agent -f
```

## Future Enhancements

- Configure SSL/TLS for secure access
- Set up automated backup for Jenkins configuration and jobs
- Implement resource limits and requests for better cluster resource management
- Add additional worker nodes for increased build capacity
- Configure node-specific build environments (Docker, specific tools)
- Implement node monitoring and alerting

*Last Updated: July 27, 2025*