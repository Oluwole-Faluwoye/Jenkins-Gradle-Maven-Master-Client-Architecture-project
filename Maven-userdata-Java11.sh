#!/bin/bash

# ----------------------------------------
# STEP 1: System Update and Install Java 11 JDK
# ----------------------------------------
sudo yum update -y
sudo amazon-linux-extras enable java-openjdk11
sudo yum clean metadata
sudo yum install -y java-11-openjdk-devel

# ----------------------------------------
# STEP 2: Set Java 11 as Default
# ----------------------------------------
sudo alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk*/bin/java 1
sudo alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-11-openjdk*/bin/javac 1
sudo alternatives --set java /usr/lib/jvm/java-11-openjdk*/bin/java
sudo alternatives --set javac /usr/lib/jvm/java-11-openjdk*/bin/javac

# ----------------------------------------
# STEP 3: Install Maven 3.9.6 Manually
# ----------------------------------------
cd /opt
sudo wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
sudo tar -xvzf apache-maven-3.9.6-bin.tar.gz
sudo ln -s apache-maven-3.9.6 maven

# ----------------------------------------
# STEP 4: Set Global Environment Variables
# ----------------------------------------
sudo tee /etc/profile.d/java.sh > /dev/null <<EOF
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

sudo tee /etc/profile.d/maven.sh > /dev/null <<EOF
export M2_HOME=/opt/maven
export PATH=\$M2_HOME/bin:\$PATH
EOF

sudo chmod +x /etc/profile.d/*.sh
source /etc/profile.d/java.sh
source /etc/profile.d/maven.sh

# ----------------------------------------
# STEP 5: Create jenkinsmaster User with Password
# ----------------------------------------
sudo useradd jenkinsmaster
echo jenkinsmaster | sudo passwd jenkinsmaster --stdin

# ----------------------------------------
# STEP 6: Enable SSH Password Authentication
# ----------------------------------------
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin no/#PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#UsePAM yes/UsePAM yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# ----------------------------------------
# STEP 7: Sudo Permissions and Ownership
# ----------------------------------------
echo "jenkinsmaster   ALL=(ALL)       NOPASSWD: ALL" | sudo tee -a /etc/sudoers
sudo chown -R jenkinsmaster:jenkinsmaster /opt

# ----------------------------------------
# STEP 8: Install Git
# ----------------------------------------
sudo yum install -y git

# ----------------------------------------
# STEP 9: Configure Maven for jenkinsmaster
# ----------------------------------------
sudo mkdir -p /home/jenkinsmaster/.m2
sudo wget https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/settings.xml -P /home/jenkinsmaster/.m2/
sudo chown -R jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.m2

# ----------------------------------------
# STEP 10: Download and Apply .bash_profile for jenkinsmaster
# ----------------------------------------
sudo su - jenkinsmaster -c "wget https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/.bash_profile -O /home/jenkinsmaster/.bash_profile"
sudo su - jenkinsmaster -c "source /home/jenkinsmaster/.bash_profile"

# ----------------------------------------
# STEP 11: Verify Tool Versions as jenkinsmaster
# ----------------------------------------
sudo su - jenkinsmaster -c "java -version"
sudo su - jenkinsmaster -c "javac -version"
sudo su - jenkinsmaster -c "mvn -version"
