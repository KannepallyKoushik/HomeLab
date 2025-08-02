# Local DNS Server Setup with Bind9

This document outlines the setup of a local DNS server using Bind9 deployed as a Docker container in the HomeLab infrastructure.

## Overview

The local DNS server is designed to provide internal domain resolution for HomeLab services while maintaining external connectivity. This setup enables clean hostname-based access to internal services and prepares the infrastructure for future external domain integration.

## Implementation Overview

### DNS Server Configuration
- **DNS Software**: Bind9
- **Deployment Method**: Docker Container
- **Host Machine**: k-worker2-large
- **Domain**: kannepally.me (purchased from Namecheap)
- **Internal Zone**: home.kannepally.me

### Network Design

#### Domain Strategy
- **Domain**: kannepally.me (purchased from Namecheap)
- **Purpose**: Enable TLS certificates from Let's Encrypt and other providers
- **Internal Zone**: home.kannepally.me for local service resolution

#### DNS Configuration
- **Primary DNS**: Bind9 container (192.168.0.150)
- **Forwarders**: 1.1.1.1 and ISP DNS server
- **Access Control**: Limited to local network only
- **IPv6**: Disabled for DNS resolution

## Implementation Steps

### Step 1: Domain Acquisition
- **Domain Purchased**: kannepally.me from Namecheap
- **Purpose**: To enable TLS certificate generation from Let's Encrypt or other providers
- **Configuration**: Basic domain setup with registrar

### Step 2: Bind9 Docker Container Setup

#### Dockercompose Configuration
```docker-compose.yml
services:
  bind9:
    container_name: homelab_dns_bind9
    image: ubuntu/bind9:latest
    environment:
      - BIND9_USER=root
      - TZ=Europe/Amsterdam
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - ./config:/etc/bind
      - ./cache:/var/cache/bind
      - ./records:/var/lib/bind
    restart: unless-stopped

#### Docker Run Command
```bash
# Running Docker compose file
docker compose up -d
```

### Step 3: Bind9 Configuration

#### Main Configuration File (named.conf)
```conf
acl internal {
    192.168.0.0/24;
    localhost;
    localnets;
};

options {
    forwarders {
        1.1.1.1;
        xx.xx.xx.xx; # // ISP DNS IP
    };
    forward only;

    allow-query { internal; };
    allow-recursion { internal; };

    # // Disable IPv6 if your network doesn’t use it
    listen-on-v6 { none; };

    # // Optional but helpful
    dnssec-validation no;
};

zone "home.kannepally.me" IN {
    type master;
    file "/etc/bind/home-kannepally-me.zone";
};
```

### Step 4: DNS Zone Configuration

#### Zone File (home-kannepally-me.zone)
```zone
$TTL 86400
@   IN  SOA ns1.home.kannepally.me. admin.home.kannepally.me. (
        2024080201  ; Serial number (YYYYMMDDNN)
        12h             ; refresh
        15m             ; retry
        3w              ; expire
        2h              ; minimum ttl
)

; Name servers
@   IN  NS  ns.home.kannepally.me.

; A records for name server
ns IN  A   192.168.0.150

; HomeLab services
k8s-control-plane       IN  A   192.168.0.110   ; K3s master node
k-worker1-mini          IN  A   192.168.0.200   ; K3s worker node 1
k-worker2-large         IN  A   192.168.0.150   ; K3s worker node 2 (also DNS server)

; Service aliases
dns             IN  CNAME   k-worker2-large.home.kannepally.me.
ci              IN  CNAME   jenkins.home.kannepally.me.

; Future services (commented out until implemented)
; monitoring     IN  A   192.168.0.100
; grafana        IN  A   192.168.0.100
; prometheus     IN  A   192.168.0.100
```

### Step 5: Router Configuration

#### TP-Link Router Setup
1. **Access Router Admin Panel**
   - Navigate to default gateway IP (typically 192.168.0.1)
   - Login with admin credentials

2. **Configure DNS Settings**
   - Go to: **Advanced** → **LAN/DHCP**
   - Set **Primary DNS Server**: `192.168.0.150` (Bind9 server)
   - Set **Secondary DNS Server**: `xx.xx.xx.xx` (ISP DNS)
   - **Save** configuration

3. **Apply Changes**
   - Reboot the router to take effect
   - Wait for all devices to reconnect

### Step 6: Client Configuration

#### Windows and macOS Machines
- Automatically received DNS configuration via DHCP from router
- No manual configuration required

#### Ubuntu Servers - Standard Configuration
For most Ubuntu servers, modified `/etc/systemd/resolved.conf`:

```conf
[Resolve]
DNS=192.168.0.150 1.1.1.1
FallbackDNS=8.8.8.8
DNSStubListener=yes
Domains=home.kannepally.me
```

**Apply Configuration:**
```bash
sudo systemctl restart systemd-resolved
```

#### Ubuntu DNS Server Host (k-worker2-large) - Special Configuration
The machine hosting the Bind9 container requires special configuration to avoid port conflicts:

**Modified `/etc/systemd/resolved.conf`:**
```conf
[Resolve]
DNS=127.0.0.1 1.1.1.1
FallbackDNS=8.8.8.8
DNSStubListener=no
Domains=home.kannepally.me
```

**Additional Steps:**
```bash
# Restart systemd-resolved
sudo systemctl restart systemd-resolved

# Update resolv.conf to use actual DNS server
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Verify /etc/resolv.conf contents
cat /etc/resolv.conf
```

**Final `/etc/resolv.conf` contents:**
```conf
nameserver 127.0.0.1
nameserver 1.1.1.1
nameserver 89.101.251.228
options edns0 trust-ad
search home.kannepally.me
```

## Issues Encountered and Solutions

### Ubuntu systemd-resolved Conflicts

#### Problem
While the TP-Link router DNS configuration was automatically applied to Windows and macOS machines via DHCP, Ubuntu servers continued using `systemd-resolved` which listens on `127.0.0.53:53`, bypassing the router's DNS settings.

#### Solution for Standard Ubuntu Servers
Modified `/etc/systemd/resolved.conf` on each Ubuntu machine:
```conf
[Resolve]
DNS=192.168.0.150 1.1.1.1
FallbackDNS=8.8.8.8
DNSStubListener=yes
Domains=home.kannepally.me
```

#### Special Case: DNS Server Host (k-worker2-large)
The machine hosting the Bind9 container required additional configuration to avoid port 53 conflicts:

**Problem**: DNSStubListener conflicts with Bind9 container port binding
**Solution**: 
1. Set `DNSStubListener=no` in `/etc/systemd/resolved.conf`
2. Point DNS to localhost (`127.0.0.1`) since Bind9 runs locally
3. Update `/etc/resolv.conf` to use the actual DNS resolver

### Port 53 Binding Issues
- **Issue**: systemd-resolved occupying port 53 prevented Docker container from binding
- **Resolution**: Disabled DNSStubListener on the DNS server host
- **Verification**: Confirmed Docker container can bind to port 53 successfully

## Testing and Verification

### DNS Resolution Testing
```bash
# Test internal domain resolution
nslookup jenkins.home.kannepally.me

# Test external domain resolution
nslookup google.com

# Verify DNS server response
dig @192.168.0.150 jenkins.home.kannepally.me
```

### Service Connectivity
```bash
# Test Jenkins access via new hostname
curl -I http://jenkins.home.kannepally.me

# Verify all internal services resolve
ping k3s-master.home.kannepally.me
ping k-worker1-mini.home.kannepally.me
ping k-worker2-large.home.kannepally.me
```

## Current Service Hostname Mapping

### Active Services
- **Jenkins**: `jenkins.home.kannepally.me` → 192.168.0.110 or 192.168.0.150 or. 192.168.0.200 (Kubernetes ingress)
- **DNS Server**: `dns.home.kannepally.me` → 192.168.0.150
- **K3s Master**: `k3s-master.home.kannepally.me` → 192.168.0.110
- **Worker Nodes**: 
  - `k-worker1-mini.home.kannepally.me` → 192.168.0.200
  - `k-worker2-large.home.kannepally.me` → 192.168.0.150

### Migration from Manual Configuration
- **Before**: Manual `/etc/hosts` entries for `jenkins.local`
- **After**: Automatic DNS resolution via `jenkins.home.kannepally.me`
- **Benefits**: No more manual host file management across the network

## Router Configuration Details

### TP-Link Router DNS Settings
**Navigation Path**: Advanced → LAN/DHCP → DNS Configuration

**Configuration Applied**:
- **Primary DNS Server**: `192.168.0.150` (Bind9 container)
- **Secondary DNS Server**: `89.101.251.228` (ISP DNS server)

**Benefits of this configuration**:
- Internal domains (*.home.kannepally.me) resolve via local Bind9
- External domains resolve via Bind9 with forwarders to public DNS
- Fallback to ISP DNS ensures internet connectivity if local DNS fails
- Automatic DHCP distribution to Windows and macOS clients

## Operational Status

### Container Status
```bash
# Check container status
docker ps | grep bind9-dns

# View container logs
docker logs bind9-dns

# Restart container if needed
docker restart bind9-dns
```

### DNS Server Health
```bash
# Check if DNS is responding
nslookup jenkins.home.kannepally.me 192.168.0.150

# Monitor DNS queries (inside container)
docker exec -it bind9-dns tail -f /var/log/named/query.log
```

## Security Implementation

### Access Control
- **ACL "internal"**: Restricts DNS queries to local network (192.168.0.0/24)
- **Query Restrictions**: Only internal networks can perform recursive queries
- **Zone Transfer**: Disabled for security

### Firewall Considerations
- **Port 53/UDP**: Open for DNS queries
- **Port 53/TCP**: Open for zone transfers (restricted to localhost)
- **Container Network**: Bound to specific interface (192.168.0.150)

## Backup and Maintenance

### Configuration Backup
```bash
# Backup DNS configuration
sudo cp -r /opt/bind9/ /backup/bind9-$(date +%Y%m%d)

# Backup zone files
docker exec bind9-dns tar -czf /tmp/zones-backup.tar.gz /etc/bind/zones/
docker cp bind9-dns:/tmp/zones-backup.tar.gz ./zones-backup-$(date +%Y%m%d).tar.gz
```

### Zone File Updates
```bash
# Update zone file
sudo nano /opt/bind9/zones/home-kannepally-me.zone

# Increment serial number in zone file (YYYYMMDDNN format)
# Reload zone without restarting container
docker exec bind9-dns rndc reload home.kannepally.me
```




## Implementation Notes



## References

- [Bind9 Official Documentation](https://bind9.readthedocs.io/)
- [Docker Bind9 Container Guide](https://hub.docker.com/r/internetsystemsconsortium/bind9)
- [DNS Best Practices for Home Labs](https://example.com/homelab-dns)

## Future Enhancements

### Completed ✅
- **Domain Acquisition**: kannepally.me purchased from Namecheap
- **Bind9 Container Deployment**: Successfully deployed on k-worker2-large
- **Local DNS Resolution**: home.kannepally.me zone operational
- **Network Integration**: TP-Link router configured, all devices using local DNS
- **Service Integration**: Jenkins accessible via jenkins.home.kannepally.me

### Planned Enhancements
- **External Domain Integration**: Configure public access routing for selected services
- **SSL Certificate Automation**: Let's Encrypt integration for TLS certificates
- **DNS over HTTPS (DoH)**: Secure DNS queries
- **Load Balancing**: Multiple DNS servers for redundancy
- **Dynamic DNS Updates**: Automatic service discovery and registration
- **Additional Services**: Expand zone file with more HomeLab services

## Implementation Notes

> **Status**: ✅ **COMPLETED**
> 
> The DNS server is fully operational and serving the local network. All machines now resolve internal services via the home.kannepally.me domain without manual /etc/hosts configuration.

**Key Achievements:**
- Eliminated manual /etc/hosts management across the network
- Enabled TLS certificate capability with purchased domain
- Centralized DNS management for all HomeLab services
- Successful integration with existing Kubernetes ingress setup

## References

- [Bind9 Official Documentation](https://bind9.readthedocs.io/)
- [Docker Bind9 Container Guide](https://hub.docker.com/r/ubuntu/bind9)
- [systemd-resolved Configuration](https://www.freedesktop.org/software/systemd/man/resolved.conf.html)
- [Namecheap Domain Management](https://www.namecheap.com/support/)

---

*Last Updated: August 2, 2025*
*Status: Implementation Complete*