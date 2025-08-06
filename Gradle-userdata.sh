#!/bin/bash

# Update and install Java 17
sudo apt update -y
sudo apt install openjdk-17-jdk -y

# Verify Java 17 installation
java -version

# Download and install compatible Gradle (7.6.1 supports Java 17)
wget -c https://services.gradle.org/distributions/gradle-7.6.1-bin.zip -P /tmp
sudo apt install unzip -y
sudo unzip -d /opt/gradle /tmp/gradle-7.6.1-bin.zip
ls /opt/gradle

# Create environment setup script for Gradle
cat << 'EOF' | sudo tee /etc/profile.d/gradle.sh
export GRADLE_HOME=/opt/gradle/gradle-7.6.1
export PATH=${GRADLE_HOME}/bin:${PATH}
EOF

# Make the script executable and load it
sudo chmod +x /etc/profile.d/gradle.sh
source /etc/profile.d/gradle.sh

# Verify Gradle version
gradle --version

# Provision Jenkins Master User
sudo useradd jenkinsmaster -m
echo "jenkinsmaster:jenkinsmaster" | sudo chpasswd

# Enable password authentication and sudo access
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "jenkinsmaster ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Set ownership of Gradle installation
sudo chown -R jenkinsmaster:jenkinsmaster /opt

# Install Git
sudo apt install git -y
