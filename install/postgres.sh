#!/bin/sh

# Install and configure PostgreSQL for local development
set -e

# Install PostgreSQL package (creates postgres system user)
# Using --needed makes this idempotent
sudo pacman -S --noconfirm --needed postgresql

# Initialize database cluster if not already done
if [ -d /var/lib/postgres/data ] && [ "$(ls -A /var/lib/postgres/data 2>/dev/null)" ]; then
  echo "PostgreSQL data directory already initialized"
else
  echo "Initializing PostgreSQL database cluster..."
  sudo -u postgres initdb -D /var/lib/postgres/data
fi

# Enable and start PostgreSQL service
if systemctl is-enabled postgresql >/dev/null 2>&1; then
  echo "PostgreSQL service already enabled"
else
  sudo systemctl enable postgresql
fi

if systemctl is-active postgresql >/dev/null 2>&1; then
  echo "PostgreSQL service already running"
else
  sudo systemctl start postgresql
fi

# Create user role matching current user for passwordless local access
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$USER'" | grep -q 1; then
  echo "PostgreSQL role '$USER' already exists"
else
  echo "Creating PostgreSQL role '$USER' with CREATEDB privilege..."
  sudo -u postgres createuser --createdb "$USER"
fi

echo "PostgreSQL setup complete"
echo "You can now use: createdb <dbname> && psql <dbname>"
