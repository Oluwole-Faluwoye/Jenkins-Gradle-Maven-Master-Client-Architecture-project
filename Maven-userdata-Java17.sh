#!/bin/bash

echo "=============================="
echo "🚀 Installing Java 17 and Maven"
echo "=============================="

# Install Java 17
sudo yum install -y java-17-amazon-corretto-devel || sudo yum install -y java-17-openjdk-devel

# Check Java
java -version || echo "⚠️ Java not found after install"

# Install Maven
MAVEN_VERSION=3.9.6
wget https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip -P /tmp
sudo unzip -q /tmp/apache-maven-${MAVEN_VERSION}-bin.zip -d /opt
sudo mv /opt/apache-maven-${MAVEN_VERSION} /opt/maven

# Set JAVA_HOME for all users
JAVA_HOME_PATH=$(dirname $(dirname $(readlink $(readlink $(which javac)))))

ENV_LINE="
# Java and Maven Env
export JAVA_HOME=$JAVA_HOME_PATH
export M2_HOME=/opt/maven
export PATH=\$JAVA_HOME/bin:\$M2_HOME/bin:\$PATH
"

# Apply to all users via /etc/profile.d
echo "$ENV_LINE" | sudo tee /etc/profile.d/java_maven.sh > /dev/null
sudo chmod +x /etc/profile.d/java_maven.sh

# Add jenkinsmaster user with password
sudo useradd jenkinsmaster
echo "jenkinsmaster:jenkinsmaster" | sudo chpasswd

# Copy env to jenkinsmaster's profile
sudo cp /etc/profile.d/java_maven.sh /home/jenkinsmaster/
echo "$ENV_LINE" | sudo tee -a /home/jenkinsmaster/.bash_profile > /dev/null
sudo chown jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.bash_profile

# Final Checks
echo "=============================="
echo "✅ Final Checks"
echo "=============================="
java -version
mvn -v || echo "⚠️ Maven not detected. Check PATH"
echo "✅ Setup Complete"
