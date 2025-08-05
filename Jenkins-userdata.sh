#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# ----------------------------------------
# Update system packages
# ----------------------------------------
yum update -y

# ----------------------------------------
# Install Java 11 (Amazon Corretto)
# ----------------------------------------
yum install -y java-11-amazon-corretto-devel

# Set Java 11 as default
alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-amazon-corretto/bin/java 20000
alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-11-amazon-corretto/bin/javac 20000
alternatives --set java /usr/lib/jvm/java-11-amazon-corretto/bin/java
alternatives --set javac /usr/lib/jvm/java-11-amazon-corretto/bin/javac

# Set JAVA_HOME globally
echo "export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto" >> /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh
chmod +x /etc/profile.d/java.sh
source /etc/profile.d/java.sh

# ----------------------------------------
# Install Jenkins
# ----------------------------------------
# Add Jenkins repo
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
yum install -y jenkins

# Set Jenkins to use Java 11
echo 'JAVA_HOME="/usr/lib/jvm/java-11-amazon-corretto"' >> /etc/sysconfig/jenkins

# Remove unsupported directives from Jenkins systemd unit (if present)
sed -i '/^StartLimitBurst/d' /usr/lib/systemd/system/jenkins.service || true
sed -i '/^StartLimitInterval/d' /usr/lib/systemd/system/jenkins.service || true

# Reload systemd and enable/start Jenkins
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# ----------------------------------------
# Install Git
# ----------------------------------------
yum install -y git

# ----------------------------------------
# Optional: Open firewall port 8080 (if firewalld is running)
# ----------------------------------------
if systemctl is-active firewalld >/dev/null 2>&1; then
  firewall-cmd --permanent --add-port=8080/tcp
  firewall-cmd --reload
fi

# ----------------------------------------
# Show Jenkins admin password and access URL
# ----------------------------------------
echo "Waiting for Jenkins to initialize..."
sleep 30

echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not ready yet. Try again in a few minutes."

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Access Jenkins at: http://$PUBLIC_IP:8080"

echo "Jenkins setup complete!"
