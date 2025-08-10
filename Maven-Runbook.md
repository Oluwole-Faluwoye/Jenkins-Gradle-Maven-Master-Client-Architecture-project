Use Maven-Java17-Shell-Script-Amazon-Linux-2023.sh to 


✅ Step-by-Step EC2 Setup Amazon linux 2023

✅ 1. Launch EC2 with This Script

In the AWS Console:

Go to EC2 → Launch Instance

Choose Amazon Linux 2023 AMI

Choose instance type (t2.micro)

Expand “Advanced details” → User data

Paste the "userdata" inside ( Maven-Java17-Shell-Script-Amazon-Linux-2023.sh ) file here

 The "userdata" will do the following : 
 
 - Install Java 17 + Maven

 - Create jenkinsmaster

 - Configure environment variables



 Now Enable password SSH login


Configure key pair, security group:

Allow port 22 (SSH)


✅Paste your userdata in your launch page of your instance 

✅Launch the instance

---------------------------------------------------------


✅Wait for the instance to finish booting (a few minutes).

Now wait and go configure your settings.xml file and pom.xml file and push them into your project repo using git ( Which means you need to create your sonarqube and Nexus instances as well)

-------------------------------------------------------------------------------

After updating your settings.xml file with the detals of your sonarqube and nexus instances, now

--------------------------------------------------------------------------------

✅SSH into Instance as jenkinsmaster


ssh jenkinsmaster@<your-Maven-Instance-public-ip>

Password: jenkinsmaster

✅ You should now be inside as the jenkinsmaster user with:

java -version         # Should show Java 17
javac -version        # Should show Java 17
mvn -version          # Should show Maven 3.9.6
echo $JAVA_HOME       # Should show /usr/lib/jvm/java-17-amazon-corretto.x86_64
echo $M2_HOME         # Should show /opt/maven

---------------------------------------------------------------------------------------------------------------


Meanwhile to set the maven environment variable in your maven instance (The same env variable you set in Jenkins and ensure Jenkins picks the right Maven agent that will it will use for the build)  

run the following commands step by step.


nano ~/.bashrc

Add Maven Environment Variables
At the bottom of the file, add:

export MAVEN_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH


 Save and Exit
In nano:

Press CTRL + O, then ENTER to save.

Press CTRL + X to exit.

5. Reload .bashrc to Apply Changes Immediately

source ~/.bashrc

6. Verify
Run:


echo $MAVEN_HOME

You should see:

/opt/maven

Then to get your path:


mvn -v


---------------------------------------------------------------------------------------------------------------------------------

Now go back to your Jenkins Configuration
-----------------------------------------------------------------------------------------------------------------



✅Now install git 

sudo dnf install git -y


✅ clone your project into the jenkinsmaster user environment



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
SETTINGS_URL="https://raw.githubusercontent.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project/refs/heads/maven-sonarqube-nexus/settings.xml"

# Create .m2 directory if not exists
mkdir -p "$M2_DIR"

# Download settings.xml
wget "$SETTINGS_URL" -O "$M2_DIR/settings.xml"

# Set correct ownership
chown -R jenkinsmaster:jenkinsmaster "$M2_DIR"

echo "✅ settings.xml downloaded and permissions set."


-------------------------------------------------------------------------------------------------------------------------------------------------
NOTE: WHEN YOU PASTE THE ABOVE COMMANDS, ENSURE TO REMOVE THE # AT THE LINES WHEREIT SHOULDN'T BEFORE SAVING THE FILE. AS IT WILL AUTOMATICALLY ADD # AT THE BACK OF ALL THE LINES
-----------------------------------------------------------------------------------------------------------------------------------------------------

Save the file 

✅After saving the settings-xml.sh file 

chmod +x settings-xml.sh
sudo ./settings-xml.sh