#!/bin/bash
set -e

#### Versions
containerd_version="1.7.27-1"
docker_ce_cli_version="28.3.3-1"
docker_ce_version="28.3.3-1"
docker_compose_plugin_version="2.39.1-1"

cpu_arch=$(uname -m)
legal_arch=("amd64" "x86_64" "aarch64")
distro_id=$(cat /etc/os-release | grep -i '^ID=' | awk -F'=' '{print tolower($2)}')
distro_ver=$(cat /etc/os-release | grep -i '^VERSION_ID=' | awk -F'=' '{print tolower($2)}' | sed 's/"//g')

# Check if cpu_arch is in legal_arch
if [[ ! " ${legal_arch[@]} " =~ " ${cpu_arch} " ]]; then
  echo "Architecture not supported."
  exit 1
fi

# Set arch based on cpu_arch
if [[ $cpu_arch == "amd64" \vert{}\vert{} $cpu_arch == "x86_64" ]]; then
  arch="amd64"
elif [[ $cpu_arch == "aarch64" ]]; then
  arch="arm64"
else
  echo "Architecture not supported."
  exit 1
fi

# Get Distro Code Name
distro_codename=$(lsb_release -cs)

containerd=containerd.io_"$containerd_version"_"$arch".deb
docker_ce_cli=docker-ce-cli_"$docker_ce_cli_version"~"$distro_id"."$distro_ver"~"$distro_codename"_"$arch".deb
docker_ce=docker-ce_"$docker_ce_version"~"$distro_id"."$distro_ver"~"$distro_codename"_"$arch".deb
docker_compose=docker-compose-plugin_"$docker_compose_plugin_version"~"$distro_id"."$distro_ver"~"$distro_codename"_"$arch".deb

echo "Downloading Docker package files..."
wget https://download.docker.com/linux/"$distro_id"/dists/"$distro_codename"/pool/stable/"$arch"/"$containerd"
wget https://download.docker.com/linux/"$distro_id"/dists/"$distro_codename"/pool/stable/"$arch"/"$docker_ce_cli"
wget https://download.docker.com/linux/"$distro_id"/dists/"$distro_codename"/pool/stable/"$arch"/"$docker_ce"
wget https://download.docker.com/linux/"$distro_id"/dists/"$distro_codename"/pool/stable/"$arch"/"$docker_compose"

# Install Docker Engine
sudo dpkg -i $docker_ce_cli
sudo dpkg -i $containerd
sudo dpkg -i $docker_ce
# Install Docker-Compose
sudo dpkg -i $docker_compose

# Remove downloaded .deb files
[ -f "$docker_ce_cli" ] && rm "$docker_ce_cli"
[ -f "$containerd" ] && rm "$containerd"
[ -f "$docker_ce" ] && rm "$docker_ce"
[ -f "$docker_compose" ] && rm "$docker_compose"

# Create Docker group only if it doesn't exist
getent group docker || sudo groupadd docker

# Add current user to Docker group
TARGET_USER="$USER"
if id vagrant &>/dev/null && [ -d "/home/vagrant" ]; then
  TARGET_USER="vagrant"
fi

echo "Adding $TARGET_USER to docker group..."
sudo usermod -aG docker "$TARGET_USER"

echo "Docker Engine version installed: $(docker --version)"
echo "Docker Compose plugin version installed: $(docker compose version)"
echo "Docker and Docker Compose installation completed successfully!"