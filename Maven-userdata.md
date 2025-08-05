#!/bin/bash

# ----------------------------------------
# STEP 1: System Update & Java 11 Install
# ----------------------------------------
sudo yum update -y
sudo amazon-linux-extras enable java-openjdk11
sudo yum clean metadata
sudo yum install -y java-11-openjdk-devel

# Set Java 11 as default (overrides other versions)
sudo alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk-*/bin/java 1
sudo alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-11-openjdk-*/bin/javac 1
sudo alternatives --set java /usr/lib/jvm/java-11-openjdk-*/bin/java
sudo alternatives --set javac /usr/lib/jvm/java-11-openjdk-*/bin/javac

# Confirm
java -version
javac -version

# ----------------------------------------
# STEP 2: Install Maven 3.9.6 Manually
# ----------------------------------------
cd /opt
sudo wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
sudo tar -xvzf apache-maven-3.9.6-bin.tar.gz
sudo ln -s apache-maven-3.9.6 maven

# ----------------------------------------
# STEP 3: Setup Global Maven Environment Variables
# ----------------------------------------
sudo tee /etc/profile.d/maven.sh > /dev/null <<EOF
export M2_HOME=/opt/maven
export PATH=\$M2_HOME/bin:\$PATH
EOF

sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# ----------------------------------------
# STEP 4: Create jenkinsmaster User with Password
# ----------------------------------------
sudo useradd jenkinsmaster
echo jenkinsmaster | sudo passwd jenkinsmaster --stdin

# ----------------------------------------
# STEP 5: Enable SSH Password Authentication
# ----------------------------------------
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Ensure PermitRootLogin is not set to 'no'
sudo sed -i 's/^PermitRootLogin no/#PermitRootLogin no/' /etc/ssh/sshd_config

# Ensure UsePAM is enabled
sudo sed -i 's/^#UsePAM yes/UsePAM yes/' /etc/ssh/sshd_config

# Restart SSH to apply changes
sudo systemctl restart sshd

# ----------------------------------------
# STEP 6: Grant jenkinsmaster Sudo and Set Permissions
# ----------------------------------------
echo "jenkinsmaster   ALL=(ALL)       NOPASSWD: ALL" | sudo tee -a /etc/sudoers
sudo chown -R jenkinsmaster:jenkinsmaster /opt

# ----------------------------------------
# STEP 7: Install Git
# ----------------------------------------
sudo yum install -y git

# ----------------------------------------
# STEP 8: Configure Maven for jenkinsmaster
# ----------------------------------------
sudo mkdir -p /home/jenkinsmaster/.m2
sudo wget https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/settings.xml -P /home/jenkinsmaster/.m2/
sudo chown -R jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.m2
sudo chown jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.m2/settings.xml

# ----------------------------------------
# STEP 9: Set .bash_profile for jenkinsmaster
# ----------------------------------------
sudo su - jenkinsmaster -c "wget https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/.bash_profile -O ~/.bash_profile"
sudo su - jenkinsmaster -c "source ~/.bash_profile"

# Confirm Maven and Java
sudo su - jenkinsmaster -c "java -version"
sudo su - jenkinsmaster -c "javac -version"
sudo su - jenkinsmaster -c "mvn -version"
