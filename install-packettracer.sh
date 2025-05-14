#!/bin/bash
set -e  # Exit on error

# Check if script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 
   echo "Please run: sudo bash $0"
   exit 1
fi

# Define variables
DEB_PACKAGE="$(pwd)/Packet_Tracer822_amd64_signed.deb"
EXTRACT_DIR="$(pwd)/pt_extract"
INSTALL_DIR="/opt/pt"
PT_VERSION="8.2.2"

echo "=== Cisco Packet Tracer $PT_VERSION Installation ==="
echo "This script will install Packet Tracer on your Fedora system."
echo ""

# Check if the DEB package exists
if [ ! -f "$DEB_PACKAGE" ]; then
    echo "ERROR: $DEB_PACKAGE not found"
    echo "Please make sure you're in the directory containing the Packet Tracer .deb file"
    exit 1
fi

# Create temporary extraction directory
echo "Creating temporary directory..."
mkdir -p "$EXTRACT_DIR"

# Extract the DEB package
echo "Extracting .deb package..."
ar x "$DEB_PACKAGE" --output="$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR/data"
tar -xf "$EXTRACT_DIR/data.tar.xz" -C "$EXTRACT_DIR/data"

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"

# Copy application files
echo "Copying application files..."
cp -r "$EXTRACT_DIR/data/opt/pt/"* "$INSTALL_DIR/"

# Create desktop entries
echo "Creating desktop entries..."
mkdir -p /usr/share/applications
cat > /usr/share/applications/cisco-pt.desktop << EOF
[Desktop Entry]
Type=Application
Exec=/opt/pt/packettracer %f
Name=Packet Tracer $PT_VERSION
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
Categories=Network;Education;
EOF

cat > /usr/share/applications/cisco-ptsa.desktop << EOF
[Desktop Entry]
Type=Application
Exec=/opt/pt/packettracer -uri=%u
Name=Packet Tracer $PT_VERSION
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
NoDisplay=true
MimeType=x-scheme-handler/pttp;
EOF

# Create symbolic link
echo "Creating symbolic link..."
ln -sf "$INSTALL_DIR/packettracer" /usr/local/bin/packettracer

# Set permissions for updatepttp
echo "Setting permissions..."
if [ -f "$INSTALL_DIR/bin/updatepttp" ]; then
    chown root:root "$INSTALL_DIR/bin/updatepttp"
    chmod 4755 "$INSTALL_DIR/bin/updatepttp"
fi

# Install MIME types
echo "Installing MIME types..."
mkdir -p /usr/share/mime/packages
if [ -d "$EXTRACT_DIR/data/usr/share/mime/packages" ]; then
    cp "$EXTRACT_DIR/data/usr/share/mime/packages/"*.xml /usr/share/mime/packages/
fi

# Register desktop entries and MIME types
echo "Registering application..."
xdg-desktop-menu install /usr/share/applications/cisco-pt.desktop
xdg-desktop-menu install /usr/share/applications/cisco-ptsa.desktop
update-mime-database /usr/share/mime || true
xdg-mime default cisco-pt.desktop x-scheme-handler/pttp

# Add environment variables to profile
echo "Setting environment variables..."
# Check if PT8HOME already exists in /etc/profile
if ! grep -q "PT8HOME=" /etc/profile; then
    echo "PT8HOME=$INSTALL_DIR" >> /etc/profile
fi

if ! grep -q "export PT8HOME" /etc/profile; then
    echo "export PT8HOME" >> /etc/profile
fi

# Clean up
echo "Cleaning up..."
rm -rf "$EXTRACT_DIR"

echo ""
echo "=== Installation Complete ==="
echo "You may need to log out and log back in for environment variables to take effect."
echo "You can start Packet Tracer by running 'packettracer' from the terminal"
echo "or by finding it in your applications menu."

