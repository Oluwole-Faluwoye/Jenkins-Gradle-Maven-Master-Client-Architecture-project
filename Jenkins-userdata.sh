#!/bin/bash

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

# Set JAVA_HOME for Jenkins service
echo 'JAVA_HOME="/usr/lib/jvm/java-11-amazon-corretto"' >> /etc/sysconfig/jenkins

# ----------------------------------------
# Install Jenkins
# ----------------------------------------
# Add Jenkins repo
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
yum install -y jenkins

# Enable and start Jenkins service
systemctl enable jenkins
systemctl start jenkins

# Restart Jenkins to pick up new JAVA_HOME
systemctl restart jenkins

# ----------------------------------------
# Install Git
# ----------------------------------------
yum install -y git

# ----------------------------------------
# Show Jenkins admin password and access URL
# ----------------------------------------
echo "Waiting for Jenkins to initialize..."
sleep 30

echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not ready yet. Try again in a few minutes."

# Display Jenkins public IP address
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Access Jenkins at: http://$PUBLIC_IP:8080"

echo "Jenkins setup complete!"
