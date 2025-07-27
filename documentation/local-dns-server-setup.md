# Local DNS Server Setup with Bind9

This document outlines the setup of a local DNS server using Bind9 deployed as a Docker container in the HomeLab infrastructure.

## Overview

The local DNS server is designed to provide internal domain resolution for HomeLab services while maintaining external connectivity. This setup enables clean hostname-based access to internal services and prepares the infrastructure for future external domain integration.

## Architecture Plan

### DNS Server Configuration
- **DNS Software**: Bind9
- **Deployment Method**: Docker Container
- **Host Machine**: k-worker2-large
- **Purpose**: Internal domain resolution and subdomain routing

### Network Design

#### External Domain Strategy
- **Plan**: Purchase a public domain for external traffic routing
- **Purpose**: Enable external access to selected HomeLab services
- **Implementation**: Future enhancement

#### Internal Domain Strategy
- **Primary Method**: Bind9 for internal hostname resolution
- **Domain Structure**: Subdomains based on the purchased main domain
- **Scope**: Local network service discovery and routing

### Router Configuration
- **Router**: TP-Link (HomeLab network gateway)
- **DNS Configuration**:
  - **Primary DNS**: External (1.1.1.1 or 8.8.8.8)
  - **Secondary DNS**: Bind9 container IP address
- **Purpose**: Fallback to external DNS for non-local domains

## Planned Implementation

### Phase 1: Domain Acquisition
- [ ] Purchase public domain
- [ ] Configure domain registrar settings
- [ ] Plan subdomain structure for internal services

### Phase 2: Bind9 Container Deployment
- [ ] Deploy Bind9 as Docker container on k-worker2-large
- [ ] Configure basic DNS zones
- [ ] Set up internal domain resolution
- [ ] Test local hostname resolution

### Phase 3: Network Integration
- [ ] Configure TP-Link router DNS settings
- [ ] Update all HomeLab machines to use new DNS configuration
- [ ] Verify external domain resolution fallback
- [ ] Test end-to-end connectivity

### Phase 4: Service Integration
- [ ] Update existing services to use internal hostnames
- [ ] Configure subdomain routing for:
  - Jenkins (jenkins.domain.com)
  - Future services
- [ ] Implement SSL certificates for internal services

## Current Service Hostname Mapping

### Existing Services
- **Jenkins**: Currently accessible via `jenkins.local`
- **Future Services**: To be documented as implemented

### Planned Internal Hostnames
```
# Internal subdomain structure (example)
jenkins.internal.yourdomain.com    → Jenkins Dashboard
k3s.internal.yourdomain.com        → Kubernetes Dashboard
monitoring.internal.yourdomain.com → Monitoring Stack
# Additional services to be added
```

## Technical Requirements

### Docker Container Specifications
- **Base Image**: bind9/bind9 (official)
- **Host Machine**: k-worker2-large (4 CPU, 16GB RAM)
- **Network**: Host networking or dedicated container network
- **Storage**: Persistent volumes for DNS zone files

### DNS Zone Configuration
- **Internal zones**: For local service resolution
- **Forwarders**: External DNS servers for internet domains
- **Security**: Access controls and query restrictions

## Router Configuration Details

### TP-Link Router Settings
```
Network Settings → DHCP → DNS Configuration:
- Primary DNS Server: 1.1.1.1 (or 8.8.8.8)
- Secondary DNS Server: [Bind9 Container IP]
```

**Benefits of this configuration**:
- External domains resolve via public DNS
- Internal domains resolve via local Bind9
- Fallback ensures internet connectivity if local DNS fails

## Security Considerations

- **Access Control**: Restrict DNS queries to local network
- **Zone Transfer**: Disable unauthorized zone transfers
- **Query Logging**: Enable for monitoring and troubleshooting
- **Firewall Rules**: Limit DNS port access to trusted networks

## Monitoring and Maintenance

### Health Checks
- Container status monitoring
- DNS resolution testing
- Query response time monitoring

### Backup Strategy
- Regular backup of DNS zone files
- Configuration backup before changes
- Disaster recovery procedures

## Future Enhancements

- **External Domain Integration**: Configure external access routing
- **DNS over HTTPS (DoH)**: Secure DNS queries
- **Load Balancing**: Multiple DNS servers for redundancy
- **Dynamic DNS**: Automatic IP address updates
- **Monitoring Dashboard**: DNS query analytics and performance metrics

## Implementation Notes

> **Status**: Planning Phase
> 
> This documentation will be updated as the implementation progresses. Each phase will include detailed configuration steps, troubleshooting guides, and lessons learned.

## References

- [Bind9 Official Documentation](https://bind9.readthedocs.io/)
- [Docker Bind9 Container Guide](https://hub.docker.com/r/internetsystemsconsortium/bind9)
- [DNS Best Practices for Home Labs](https://example.com/homelab-dns)

---

*Last Updated: July 27, 2025*