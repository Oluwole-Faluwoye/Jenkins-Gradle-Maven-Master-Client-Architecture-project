Amazon Linux 2 

open port 8080

T2. medium


Userdata for Jenkins 

#!/bin/bash
# Download your Jenkins setup script from GitHub and execute it
curl -s https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/Jenkins-userdata.sh | bash



Step 1: Enable the Amazon Linux Extras repo for Java 11

sudo amazon-linux-extras enable java-openjdk11
sudo yum clean metadata


✅ Step 2: Install Java 11 JDK

sudo yum install -y java-11-openjdk-devel
This installs JDK 11, including the compiler javac.

✅ Step 3: Set Java 11 as the default
Amazon Linux 2 might already have Java 1.8 or 17 installed, so now we’ll use alternatives to enforce Java 11:

🔁 Set default Java version:

sudo alternatives --config java
Select the option that points to Java 11 (usually something like /usr/lib/jvm/java-11-openjdk/bin/java).
Enter the corresponding number (e.g., 2) and press Enter.

🔁 Set default javac version:

sudo alternatives --config javac
Again, choose the one for Java 11.

✅ Step 4: Set JAVA_HOME globally
🗂 Option A: Set it via /etc/profile.d/java.sh


echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" | sudo tee /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java.sh
sudo chmod +x /etc/profile.d/java.sh
source /etc/profile.d/java.sh
This sets the environment variable system-wide for all users, including Jenkins, Maven, etc.

✅ Step 5: Confirm setup
Run the following:


java -version
javac -version
echo $JAVA_HOME
You should see something like:


openjdk version "11.0.25" 2025-04-16
javac 11.0.25
/usr/lib/jvm/java-11-openjdk


-------------------------------------------------------------------------------------
NOW WE NEED TO INSTALL Jenkins that is packaged with JAVA 11

You’ll need to install a Jenkins version that fully supports Java 11, including a Java 11-compatible remoting.jar.

🎯 Use Jenkins 2.361.4 or earlier
Jenkins 2.361.4 is the last LTS version that works fully with Java 11.

After that, newer versions of Jenkins (and its agents) require Java 17.



1. Install Jenkins 2.361.4

sudo wget https://get.jenkins.io/redhat-stable/jenkins-2.361.4-1.1.noarch.rpm

sudo yum install -y jenkins-2.361.4-1.1.noarch.rpm

This will give you:

A Jenkins core that runs on Java 11

An agent (remoting.jar) that is also Java 11-compatible

2. Restart Jenkins

sudo systemctl daemon-reexec
sudo systemctl restart jenkins

3. Confirm Java version on master

java -version
Should show Java 11.
-------------------------------------------------------------------------------------

🔁 Optional: Set for Jenkins specifically
If you're using a Jenkins user (e.g., jenkinsmaster), add it to their .bash_profile:


echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> /home/jenkinsmaster/.bash_profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /home/jenkinsmaster/.bash_profile
Then:


sudo chown jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.bash_profile


 Configure Master and Clinet Configuration
Click on "Manage Jenkins" >> Click "Nodes and Cloud" >> Click "New Node"
Click New Node
Node name: Maven-Build-Env
Type: Permanent Agent >> Click CREATE
3.1. Configure "Maven-Build-Env"
Name: Maven-Build-Env
Number of Executors: 5 (for example, maximum jobs to execute at a time)
Remote root directory: /opt/maven-builds
Labels: Maven-Build-Env
Usage: Use this node as much as possible
Launch method: Launch agents via SSH
Host: Provide IP of Maven-Build-Server
Credentials:
Login to Maven VM
Run the following commands
sudo su

passwd root

provide the password as "root"


✅ 2. Allow root login over SSH

Edit the SSH config file:

vi /etc/ssh/sshd_config 

Look for:

#PermitRootLogin prohibit-password

➡️ Change it to:


PermitRootLogin yes

✅ Uncomment it (remove the #) and set to yes.

Also ensure this is set:

PasswordAuthentication yes

This enables login with passwords (instead of just key pairs).

✅ 3. Restart the SSH service

sudo systemctl restart sshd

✅ 4. (Optional but recommended) Allow PAM
Also ensure this is enabled in /etc/ssh/sshd_config:


Restart SSH again if you change it.

systemctl restart sshd

✅ 5. Test root SSH login from your terminal

ssh root@<MAVEN_VM_PUBLIC_IP>

Back to Jenkins UI

Credentials:
Click on Add / Jenkins and Select Username and Password
Username: root
Password: root
ID: Maven-Build-Env-Credential
Save
Credentials: Select Maven-Build-Env-Credential
Host Key Verification Strategy: Non Verifying Verification Strategy
Availability: Keep this agent online as much as possible
NODE PROPERTIES
Select Environment variables

Click Add
1st Variable:
Name: MAVEN_HOME
Value: /usr/share/apache-maven
2nd Variable:
Name: PATH
Value: $MAVEN_HOME/bin:$PATH
Click SAVE

NOTE: Make sure the Agent Status shows Agent successfully connected and online on the Logs
NOTE: Repeat the process for adding additional Nodes
3.2. Configure "Gradle-Build-Env"
Click New Node

Node name: Gradle-Build-Env
Type: Permanent Agent >> Click CREATE
Name: Gradle-Build-Env

Number of Executors: 5 (for example, maximum jobs to execute at a time)

Remote root directory: /opt/gradle-builds

Labels: Gradle-Build-Env

Usage: Use this node as much as possible

Launch method: Launch agents via SSH

Host: Provide IP of Gradle-Build-Server
Credentials:
Login to Gradle VM
Run the following commands
sudo su
passwd root
provide the password as "root", "root"
vi /etc/ssh/sshd_config (:/PasswordAuthentication)
systemctl restart sshd
Credentials:
Click on Add / Jenkins and Select Username and Password
Username: root
Password: root
ID: Gradle-Build-Env-Credential
Save
Credentials: Select Gradle-Build-Env-Credential
Host Key Verification Strategy: Non Verifying Verification Strategy
Availability: Keep this agent online as much as possible
NODE PROPERTIES

Select Environment variables

Click Add
1st Variable:
Name: GRADLE_HOME
Value: /opt/gradle/gradle-6.8.3
2nd Variable:
Name: PATH
Value: $GRADLE_HOME/bin:$PATH
Click SAVE

NOTE: Make sure the Agent Status shows Agent successfully connected and online on the Logs

NOTE: Repeat the process for adding additional Nodes

4️⃣ Plugin Installation Before Job Creation
Install: Delivery Pipeline plugin
Click on Dashboard on Jenkins
Click on The + on your Jenkins Dashboard and Configure the View
Select Enable start of new pipeline build
Pipelines >> Components >> Click Add
Name: Maven-Continuous-Integration-Pipeline or Gradle-Continuous-Integration-Pipeline
Initial Job: Select either the Maven Build Job or 1st Job or Gradle Build Job or 1st Job
APPLY and SAVE
5️⃣ CREATE PROJECT PIPELINE JOBS
5.1. Create Maven Build, Test and Deploy Job
Maven Build Job
Click on New Item
Name: Maven-Continuous-Integration-Pipeline-Build
Type: Freestyle
Click: OK
Select: GitHub project, Project url: YOUR_MAVEN_PROJECT_REPOSITORY
Select Restrict where this project can be run:, Label Expression: Maven-Build-Env
Select Git, Repository URL: YOUR_MAVEN_PROJECT_REPOSITORY
Branches to build: */main or master
Build Steps: Execute Shell
Command: mvn clean build
APPLY and SAVE
Maven SonarQube Test Job
Click on New Item
Name: Maven-Continuous-Integration-Pipeline-SonarQube-Test
Type: Freestyle
Click: OK
Select: GitHub project, Project url: YOUR_MAVEN_PROJECT_REPOSITORY
Select Restrict where this project can be run:, Label Expression: Maven-Build-Env
Select Git, Repository URL: YOUR_MAVEN_PROJECT_REPOSITORY
Branches to build: */main or master
Build Steps: Execute Shell
Command: """mvn sonar:sonar
-Dsonar.projectKey=Maven-JavaWebApp-Analysis
-Dsonar.host.url=http://PROVIDE_PRIVATE_IP:9000
-Dsonar.login=SONARQUBE_PROJECT_AUTHORIZATION_TOKEN"""
APPLY and SAVE
Maven Nexus Upload Job
Click on New Item
Name: Maven-Continuous-Integration-Pipeline-Nexus-Upload

Type: Freestyle

Click: OK

Select: GitHub project, Project url: YOUR_MAVEN_PROJECT_REPOSITORY
Select Restrict where this project can be run:, Label Expression: Maven-Build-Env

Select Git, Repository URL: YOUR_MAVEN_PROJECT_REPOSITORY

Branches to build: */main or master

Build Steps: Execute Shell

Command: mvn deploy
APPLY and SAVE

5.2. Create Gradle Build, Test and Deploy Job
Gradle Build Job
Click on New Item
Name: Gradle-Continuous-Integration-Pipeline-Build
Type: Freestyle
Click: OK
Select: GitHub project, Project url: YOUR_GRADLE_PROJECT_REPOSITORY
Select Restrict where this project can be run:, Label Expression: Gradle-Build-Env
Select Git, Repository URL: YOUR_GRADLE_PROJECT_REPOSITORY
Branches to build: */main or master
Build Steps: Execute Shell
Command: gradle clean build
APPLY and SAVE
Gradle SonarQube Test Job
Click on New Item
Name: Gradle-Continuous-Integration-Pipeline-SonarQube-Test
Type: Freestyle
Click: OK
Select: GitHub project, Project url: YOUR_GRADLE_PROJECT_REPOSITORY
Select Restrict where this project can be run:, Label Expression: Gradle-Build-Env
Select Git, Repository URL: YOUR_GRADLE_PROJECT_REPOSITORY
Branches to build: */main or master
Build Steps: Execute Shell
Command: gradle sonarqube
APPLY and SAVE
Gradle Nexus Deploy Job
Click on New Item
Name: Gradle-Continuous-Integration-Pipeline-Nexus-Upload
Type: Freestyle
Click: OK
Select: GitHub project, Project url: YOUR_GRADLE_PROJECT_REPOSITORY
Select Restrict where this project can be run:, Label Expression: Gradle-Build-Env
Select Git, Repository URL: YOUR_GRADLE_PROJECT_REPOSITORY
Branches to build: */main or master
Build Steps: Execute Shell
Command: gradle publish
APPLY and SAVE
6️⃣ JOB INTEGRATION
6.1. Integrate The Maven JOBS Together To Create a CI Pipeline
Click on your First Job > Click Configure
Scroll to Post-build Actions Click Add P-B-A >> Projects to build "Select" Second Job
Click on your Second Job > Click Configure
Scroll to Post-build Actions Click Add P-B-A >> Projects to build "Select" Third Job
6.2. Integrate The Gradle JOBS Together To Create a CI Pipeline
Click on your First Job > Click Configure
Scroll to Post-build Actions Click Add P-B-A >> Projects to build "Select" Second Job
Click on your Second Job > Click Configure
Scroll to Post-build Actions Click Add P-B-A >> Projects to build "Select" Third Job
7️⃣ TEST YOUR PIPELINE