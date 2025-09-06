#!/bin/bash

# MariaDB Development Setup Script
# Sets up MariaDB for development use with basic configuration

# Exit on any error
set -e

echo "=== MariaDB Development Setup ==="

# Check if MariaDB is installed
if ! command -v mariadb &> /dev/null; then
    echo "Error: MariaDB is not installed. Run the main arch-install.sh first."
    exit 1
fi

echo "MariaDB version: $(mariadb --version)"

# Initialize MariaDB data directory (only if not already initialized)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    echo "✅ MariaDB data directory initialized"
else
    echo "✅ MariaDB data directory already exists"
fi

# Enable MariaDB service (don't start automatically - let user decide)
echo "Enabling MariaDB service..."
sudo systemctl enable mariadb

echo "✅ MariaDB service enabled (will start on boot)"

# Display status
echo ""
echo "=== MariaDB Setup Status ==="
echo "Service enabled: $(systemctl is-enabled mariadb)"
echo "Service status: $(systemctl is-active mariadb || echo 'inactive')"
echo ""

echo "=== MariaDB Setup Complete ==="
echo "Next steps:"
echo "1. Start MariaDB: sudo systemctl start mariadb"
echo "2. Secure installation: sudo mariadb-secure-installation"
echo "3. Create your database and user:"
echo "   sudo mariadb -u root -p"
echo "   CREATE DATABASE your_project_db;"
echo "   CREATE USER 'your_user'@'localhost' IDENTIFIED BY 'your_password';"
echo "   GRANT ALL PRIVILEGES ON your_project_db.* TO 'your_user'@'localhost';"
echo "   FLUSH PRIVILEGES;"
echo "   EXIT;"
echo ""
echo "Alternative: Use MariaDB in Docker:"
echo "   docker run -d --name mariadb-dev -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=mydb -p 3306:3306 mariadb:latest"
