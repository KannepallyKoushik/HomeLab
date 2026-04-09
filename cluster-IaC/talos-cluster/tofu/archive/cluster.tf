# ──────────────────────────────
# Wait for Talos VM to Respond
# ──────────────────────────────
# Talos starts a small API on port 50000 (gRPC) when booted.
# We'll ping until that port opens.

# resource "null_resource" "wait_for_talos" {
#   depends_on = [proxmox_virtual_environment_vm.talos_cp_01]

#   provisioner "local-exec" {
#     command = <<EOT
#     echo "Waiting for Talos API on ${var.talos_cp_01_ip_addr}:50000..."
#     for i in {1..60}; do
#       nc -zv ${var.talos_cp_01_ip_addr} 50000 && break
#       echo "Still waiting... ($i/60)"
#       sleep 10
#     done
#     EOT
#   }
# }

# ──────────────────────────────
# Generate Talos Configuration Locally
# ──────────────────────────────
# Generate Talos configuration locally
# resource "null_resource" "generate_talos_configs" {
#   depends_on = [proxmox_virtual_environment_vm.talos_cp_01]

#   provisioner "local-exec" {
#     command = <<EOT
#       mkdir -p ./talos-configs
#       talosctl gen config talos-cluster https://${var.talos_cp_01_ip_addr}:6443 \
#         --output-dir=./talos-configs \
#         --install-disk /dev/vda \
#         --with-secrets
#     EOT
#   }
# }

# # ──────────────────────────────
# # Apply Talos Configuration Automatically
# # ──────────────────────────────

# resource "null_resource" "apply_talos_config" {
#   depends_on = [null_resource.wait_for_talos]

#   provisioner "local-exec" {
#     command = <<EOT
#     echo "Applying Talos control plane configuration..."
#     talosctl apply-config \
#       --insecure \
#       --nodes ${var.talos_cp_01_ip_addr} \
#       --file ${path.module}/talos-configs/controlplane.yaml
#     EOT
#   }
# }