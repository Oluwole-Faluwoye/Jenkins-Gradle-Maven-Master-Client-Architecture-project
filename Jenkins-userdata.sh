#!/bin/bash
# Update the system
yum update -y
# Install Java 17 (Amazon Corretto)
amazon-linux-extras enable corretto17
yum install -y java-17-amazon-corretto-devel
# Add Jenkins repository
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
# Install Jenkins
yum install -y jenkins
# Start and enable Jenkins service
systemctl enable jenkins
systemctl start jenkins
# Wait for Jenkins to initialize
echo "Waiting for Jenkins to start..."
sleep 30
# Retrieve and display initial admin password
echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not ready yet. Try again in a few minutes."
# Optional: Open firewall port 8080 if using firewalld
# systemctl status firewalld >/dev/null 2>&1
# if [ $? -eq 0 ]; then
#     firewall-cmd --permanent --add-port=8080/tcp
#     firewall-cmd --reload
# fi
echo "Setup complete!"
echo "Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"

# Installing Git
yum install git -y