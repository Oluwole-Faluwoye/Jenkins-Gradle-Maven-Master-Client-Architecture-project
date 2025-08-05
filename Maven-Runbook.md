Use Maven-userdata.sh (from your repo) as a cloud-init script to:

Install Java 11 + Maven

Create jenkinsmaster

Configure environment variables

Enable password SSH login

Set up Maven and Nexus credentials

✅ Step-by-Step EC2 Setup (Amazon Linux 2)
✅ 


✅ 1. Launch EC2 with This Script
In the AWS Console:

Go to EC2 → Launch Instance

Choose Amazon Linux 2 AMI

Choose instance type (e.g., t2.micro)

Expand “Advanced details” → User data

Paste the script above

Configure key pair, security group:

Allow port 22 (SSH)

(Optional) Allow port 8080 for Jenkins web UI

This will download and run your Maven-userdata.sh from your GitHub repo automatically during launch.

#!/bin/bash
cd /tmp
wget https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/Maven-userdata.sh -O userdata.sh
chmod +x Maven-userdata.sh
./Maven-userdata.sh

Launch the instance

✅ 3. SSH into Instance as jenkinsmaster
Wait for the instance to finish booting (a few minutes).

Then:

bash
Copy
Edit
ssh jenkinsmaster@<your-ec2-public-ip>
Password: jenkinsmaster

✅ You should now be inside as the jenkinsmaster user with:

Java 11 as default

Maven 3.9.6 installed

Environment variables set

.bash_profile loaded

settings.xml in place

🔍 How to Confirm It's Working
Once logged in via SSH:

bash
Copy
Edit
java -version         # Should show Java 11
javac -version        # Should show Java 11
mvn -version          # Should show Maven 3.9.6
echo $JAVA_HOME       # Should show /usr/lib/jvm/java-11-openjdk
echo $M2_HOME         # Should show /opt/maven
ls ~/.m2/settings.xml # Should exist