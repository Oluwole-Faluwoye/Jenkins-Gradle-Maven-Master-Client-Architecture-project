#!/bin/bash
set -euo pipefail

echo "=== Updating system ==="
sudo yum update -y

echo "=== Installing Java 17 (Amazon Corretto) ==="
sudo amazon-linux-extras enable corretto17
sudo yum clean metadata
sudo yum install -y java-17-amazon-corretto-devel

echo "=== Installing Maven 3.9.6 manually ==="
MAVEN_VERSION=3.9.6
cd /opt
sudo wget -q https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo ln -sfn apache-maven-${MAVEN_VERSION} maven
sudo rm -f apache-maven-${MAVEN_VERSION}-bin.tar.gz

echo "=== Setting system-wide environment variables ==="
sudo tee /etc/profile.d/java_maven.sh > /dev/null <<EOF
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
export M2_HOME=/opt/maven
export PATH=\$JAVA_HOME/bin:\$M2_HOME/bin:\$PATH
EOF
sudo chmod +x /etc/profile.d/java_maven.sh
source /etc/profile.d/java_maven.sh

echo "=== Creating jenkinsmaster user if missing ==="
if ! id -u jenkinsmaster >/dev/null 2>&1; then
  sudo useradd jenkinsmaster
fi

echo "=== Setting password for jenkinsmaster ==="
echo "jenkinsmaster:jenkinsmaster" | sudo chpasswd

echo "=== Downloading .bash_profile for jenkinsmaster ==="
sudo tee /home/jenkinsmaster/.bash_profile > /dev/null <<'EOB'
# .bash_profile for jenkinsmaster
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
export M2_HOME=/opt/maven
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
EOB
sudo chown jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.bash_profile

echo "=== Enabling SSH password authentication ==="
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
sudo systemctl restart sshd

echo "=== Granting jenkinsmaster passwordless sudo ==="
echo "jenkinsmaster   ALL=(ALL)       NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkinsmaster
sudo chmod 440 /etc/sudoers.d/jenkinsmaster

echo "=== Fixing permissions on /opt ==="
sudo chown -R jenkinsmaster:jenkinsmaster /opt

echo "=== Installing Git ==="
sudo yum install -y git

echo "=== Downloading Maven settings.xml for jenkinsmaster ==="
sudo mkdir -p /home/jenkinsmaster/.m2
sudo wget -q https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/settings.xml -P /home/jenkinsmaster/.m2/
sudo chown -R jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.m2

echo "=== Verifying installations as jenkinsmaster user ==="
sudo -i -u jenkinsmaster bash -c "java -version"
sudo -i -u jenkinsmaster bash -c "javac -version"
sudo -i -u jenkinsmaster bash -c "mvn -v"

echo "=== Setup complete ==="
