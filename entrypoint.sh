#!/bin/zsh
set -e

echo "Initializing container services..."

# 1. Create SSH privilege separation directory (required for sshd)
mkdir -p /run/sshd
chmod 755 /run/sshd

# 2. Start D-Bus (required for XFCE desktop session & XRDP)
mkdir -p /run/dbus
dbus-daemon --system --fork 2>/dev/null || true

# 3. Start SSH daemon on standard port 22
echo "[+] Starting SSH server (port 22)..."
/usr/sbin/sshd

# 4. Start XRDP session manager & gateway for RDP desktop access
echo "[+] Starting XRDP server (port 3389)..."
xrdp-sesman &
xrdp &

# Brief pause to allow daemons to bind to sockets & initialize
sleep 2

echo "--------------------------------------------------------"
echo "[+] Services are ready."
echo "    SSH:  ssh root@<container-ip>"
echo "    RDP:  Connect with any RDP client -> <container-ip>:3389"
echo "    Desktop: XFCE4 will launch automatically on RDP login"
echo "--------------------------------------------------------"

# Execute the CMD defined in Dockerfile (interactive zsh login shell)
exec "$@"