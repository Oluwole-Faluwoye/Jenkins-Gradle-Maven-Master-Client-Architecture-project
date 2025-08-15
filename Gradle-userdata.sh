#!/bin/bash
set -e  # Exit if any command fails

# Update system
apt update -y

# Install Java 17
apt install -y openjdk-17-jdk

# Verify Java installation
java -version

# Create Gradle installation directory
mkdir -p /opt/gradle

# Download and extract Gradle 7.6.1
wget -c https://services.gradle.org/distributions/gradle-7.6.1-bin.zip -P /tmp
apt install -y unzip
unzip -d /opt/gradle /tmp/gradle-7.6.1-bin.zip

# Add Gradle to PATH for all users (system-wide)
echo "export GRADLE_HOME=/opt/gradle/gradle-7.6.1" | tee /etc/profile.d/gradle.sh
echo 'export PATH=$GRADLE_HOME/bin:$PATH' | tee -a /etc/profile.d/gradle.sh
chmod +x /etc/profile.d/gradle.sh

# Also export immediately for this script run
export GRADLE_HOME=/opt/gradle/gradle-7.6.1
export PATH=$GRADLE_HOME/bin:$PATH

# Verify Gradle now works
gradle -v

# Create Jenkins master user
useradd jenkinsmaster -m
echo "jenkinsmaster:jenkinsmaster" | chpasswd

# Ensure Gradle PATH is also in jenkinsmaster's shell immediately
echo "export GRADLE_HOME=/opt/gradle/gradle-7.6.1" >> /home/jenkinsmaster/.bashrc
echo 'export PATH=$GRADLE_HOME/bin:$PATH' >> /home/jenkinsmaster/.bashrc
chown jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.bashrc

# Enable password authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# Give sudo access to Jenkins master
echo "jenkinsmaster ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Change ownership of /opt
chown -R jenkinsmaster:jenkinsmaster /opt

# Install Git
apt install -y git
