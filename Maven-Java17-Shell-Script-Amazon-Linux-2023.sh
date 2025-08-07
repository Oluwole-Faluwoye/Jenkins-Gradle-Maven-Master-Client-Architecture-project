#!/bin/bash

set -e

# ----------------------------------------
# 1. Update system
# ----------------------------------------
dnf update -y

# ----------------------------------------
# 2. Install Java 17 and compiler
# ----------------------------------------
dnf install -y java-17-amazon-corretto java-17-amazon-corretto-devel

alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-amazon-corretto/bin/java 20000
alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-amazon-corretto/bin/javac 20000

# ----------------------------------------
# 3. Install Maven 3.9.6 manually
# ----------------------------------------
cd /opt
MAVEN_VERSION=3.9.6
wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
tar -xvzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
ln -s apache-maven-${MAVEN_VERSION} maven

# ----------------------------------------
# 4. Make Maven available system-wide
# ----------------------------------------
tee /etc/profile.d/maven.sh > /dev/null << 'EOF'
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
EOF

chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# ----------------------------------------
# 5. Create jenkinsmaster user
# ----------------------------------------
useradd -m jenkinsmaster
echo 'jenkinsmaster:jenkinsmaster' | chpasswd

# Allow passwordless sudo
echo "jenkinsmaster ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set ownership of Maven to jenkinsmaster
chown -R jenkinsmaster:jenkinsmaster /opt/maven*
chown -R jenkinsmaster:jenkinsmaster /opt/apache-maven-${MAVEN_VERSION}
chown -R jenkinsmaster:jenkinsmaster /opt/maven

# Ensure Maven is loaded in their shell
echo "source /etc/profile.d/maven.sh" >> /home/jenkinsmaster/.bashrc
echo "source /etc/profile.d/maven.sh" >> /home/jenkinsmaster/.bash_profile

# ----------------------------------------
# 6. Enable password SSH login
# ----------------------------------------
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# ----------------------------------------
# 7. (Optional) Open port 22 via firewalld if you’re using it
# ----------------------------------------
if command -v firewall-cmd >/dev/null 2>&1; then
  firewall-cmd --permanent --add-port=22/tcp
  firewall-cmd --reload
fi
