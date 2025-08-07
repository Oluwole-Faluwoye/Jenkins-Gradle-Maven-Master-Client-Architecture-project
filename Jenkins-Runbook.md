Amazon Linux 2 

open port 8080

T2. medium


Userdata for Jenkins 

#!/bin/bash
# Download your Jenkins setup script from GitHub and execute it
curl -s https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/Jenkins-userdata.sh | bash



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
Host: Provide Private IP of Maven-Build-Server
Credentials:

------------------------------------------------------------------------------------

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

✅ 3. (Optional but recommended) Allow PAM
Also ensure this is enabled in /etc/ssh/sshd_config:

Find #UsePAM no change it to UsePAM yes


✅ 4.Restart SSH again if you change it.

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
Value: /opt/maven
2nd Variable:
Name: PATH
Value: $MAVEN_HOME/bin:$PATH
Click SAVE

NOTE: Make sure the Agent Status shows Agent successfully connected and online on the Logs

----------------------------------------------------------------------------

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
----------------------------------------------------------------------------------------------------------------------------------------------------

Our Maven Node is up but the diskspace where it is running is low so here is one of the option to sort that, we can either mount more space or disable or reduce the threshold for diskspace in Jenkins settings 


Option 3: Lower Jenkins Disk Space Threshold
You can configure Jenkins to accept lower disk space:

Go to Manage Jenkins → Nodes.

Click the node having the problem.

Click Configure.

Scroll down to Node Properties → Tool Locations or Environment Variables.

Check “Custom Workspace” or “Disk Space Monitoring” and adjust the threshold.

You can also disable disk space monitoring here.


---------------------------------------------------------------------------------



setting up Gradle on Jenkins UI

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

Host: Provide Private IP of Gradle-Build-Server
Credentials:

------------------------------------------------------------------------------------------------------------------------------
Login to Gradle VM
-------------------------------------------------------------------------------------------------------------------------------


Run the following commands
sudo su
passwd root
provide the password as "root", "root"

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

✅ 3. (Optional but recommended) Allow PAM
Also ensure this is enabled in /etc/ssh/sshd_config:

Find #UsePAM no change it to UsePAM yes

Als find #PubkeyAuthentication yes    and uncomment it (i.e remove the #)


✅ 4.Restart SSH again if you change it.



systemctl restart sshd

✅ 5. There is a file in your sshd which is sshd_config.d/ it wil currently over ride thepassword authentication you set inside the sshd file so you need to change it to yes or comment it 

run the command: 

sudo grep -r PasswordAuthentication /etc/ssh/sshd_config.d/


you should have : 

/etc/ssh/sshd_config.d/60-cloudimg-settings.conf:PasswordAuthentication no

This overrides your main config and disables password authentication.


How to fix it:

Edit the file:


sudo nano /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

Change this line:


PasswordAuthentication no


to


PasswordAuthentication yes

Save and exit (Ctrl + O, Enter, Ctrl + X).

Restart sshd to apply changes:


sudo systemctl restart sshd

Verify the effective config again:


sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication'

It should now output:


permitrootlogin yes
passwordauthentication yes


Now try to SSH as root with password:


Test root SSH login from your terminal

ssh root@<GRADLE_VM_PUBLIC_IP>
 ------------------------------------------------------------------------------------------------

To shorten your PATH like this:

Edit your shell config file to persist the variables after reboot or re-login:


nano ~/.bashrc

🔽 Then add these lines at the end:


export GRADLE_HOME=/opt/gradle/gradle-7.6.1
export PATH=$GRADLE_HOME/bin:$PATH

💾 Save and exit (CTRL+O, ENTER, then CTRL+X).

Then reload the file to apply changes immediately:


source ~/.bashrc

Check if Gradle is now working:

gradle -v
------------------------------------------------------------------------------------------------------------------------

Credentials:
Click on Add / Jenkins and Select Username and Password
Username: root
Password: root
ID: Gradle-Build-Env-Credential
Save
Credentials: Select Gradle-Build-Env-Credential
Host Key Verification Strategy: Non Verifying Verification Strategy
--------------------------------------------------------------------------------------------------------------------


NOTE: (In prod, do not set this to Non Verifying verificatin strategy)  This is how to go about it.   

✅ Step-by-Step Fix
🛠 Step 1: Create the .ssh directory (if not present)

SSH into your Jenkins master and run:


sudo mkdir -p /var/lib/jenkins/.ssh
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh


🛠 Step 2: Add the slave’s SSH host key to known_hosts
Run:


sudo -u jenkins ssh-keyscan -H (Your_Gradle_Private_IP) >> /var/lib/jenkins/.ssh/known_hosts
sudo chmod 644 /var/lib/jenkins/.ssh/known_hosts

This registers the slave's host key, so Jenkins trusts it.

--------------------------------------------------------------------------------------------------------------------------

Availability: Keep this agent online as much as possible

NODE PROPERTIES

Select Environment variables

Click Add
1st Variable:
Name: GRADLE_HOME
Value: /opt/gradle/gradle-7.6.1
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