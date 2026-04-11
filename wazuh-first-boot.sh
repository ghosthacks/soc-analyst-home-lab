#!/bin/bash
# Check if Wazuh is already installed
if [ -f /usr/share/wazuh-indexer/bin/opensearch ]; then
    echo "Wazuh already installed, skipping installation"
    exit 0
fi

echo "Installing Wazuh for the first time..."

# Install Wazuh
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh -a -o
rm wazuh-install.sh

# Fix permissions
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/backup 2>/dev/null || true
chown -R wazuh-indexer:wazuh-indexer /var/log/wazuh-indexer 2>/dev/null || true
chmod 750 /etc/wazuh-indexer/backup 2>/dev/null || true

# Enable logall and vulnerability detection permanently
if [ -f /var/ossec/etc/ossec.conf ]; then
    echo "Configuring Wazuh settings..."
    sed -i 's|<logall>no</logall>|<logall>yes</logall>|g' /var/ossec/etc/ossec.conf
    sed -i 's|<logall_json>no</logall_json>|<logall_json>yes</logall_json>|g' /var/ossec/etc/ossec.conf
    sed -i '/<vulnerability-detector>/,/<\/vulnerability-detector>/ s|<enabled>no</enabled>|<enabled>yes</enabled>|' /var/ossec/etc/ossec.conf
    sed -i '/<provider name="debian">/,/<\/provider>/ s|<enabled>no</enabled>|<enabled>yes</enabled>|' /var/ossec/etc/ossec.conf
    echo "✅ Wazuh config updated: logall enabled, vulnerability detector enabled"
fi

echo "Wazuh installation complete"
