Use Maven-Java17-Shell-Script-Amazon-Linux-2023.sh to 

Install Java 17 + Maven

Create jenkinsmaster

Configure environment variables

Enable password SSH login


✅ Step-by-Step EC2 Setup (Amazon Linux 2)
✅ 


✅ 1. Launch EC2 with This Script
In the AWS Console:

Go to EC2 → Launch Instance

Choose Amazon Linux 2023 AMI

Choose instance type (e.g., t2.micro)

Expand “Advanced details” → User data

Paste the script above

Configure key pair, security group:

Allow port 22 (SSH)

(Optional) Allow port 8080 for Jenkins web UI

✅Paste your userdata in your launch page of your instance 

✅Launch the instance

✅SSH into Instance as jenkinsmaster

✅Wait for the instance to finish booting (a few minutes).

Then:

ssh jenkinsmaster@<your-ec2-public-ip>
Password: jenkinsmaster

✅ You should now be inside as the jenkinsmaster user with:

java -version         # Should show Java 17
javac -version        # Should show Java 17
mvn -version          # Should show Maven 3.9.6
echo $JAVA_HOME       # Should show /usr/lib/jvm/java-17-amazon-corretto.x86_64
echo $M2_HOME         # Should show /opt/maven

✅Now install git 

sudo dnf install git -y


✅ clone your project into the jenkinsmaster user environment

✅ Here's how to fix it:
🔹 Option 1: Clone into a directory where jenkinsmaster has permission (home directory)

cd ~


git clone https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

cd realworld-cicd-pipeline-project

✅ Checkout to the branch you have your code 

git checkout maven-sonarqube-nexus



✅ Create a settings-xml.sh file with 

vi settings-xml.sh



✅Paste the following commands

-----------------------------------------------------------------------------------



#!/bin/bash

# Variables
USER_HOME="/home/jenkinsmaster"
M2_DIR="$USER_HOME/.m2"
SETTINGS_URL="https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/settings.xml"

# Create .m2 directory if not exists
mkdir -p "$M2_DIR"

# Download settings.xml
wget "$SETTINGS_URL" -O "$M2_DIR/settings.xml"

# Set correct ownership
chown -R jenkinsmaster:jenkinsmaster "$M2_DIR"

echo "✅ settings.xml downloaded and permissions set."

-----------------------------------------------------------------------------------


✅After saving the settings-xml.sh file 

chmod +x settings-xml.sh
sudo ./settings-xml.sh