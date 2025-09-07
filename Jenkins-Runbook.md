Amazon Linux 2 

open port 8080

T2. medium or t3.medium


Userdata for Jenkins 

#!/bin/bash
# Download your Jenkins setup script from GitHub and execute it
curl -s https://raw.githubusercontent.com/Oluwole-Faluwoye/Jenkins-Gradle-Maven-Master-Client-Architecture-project/refs/heads/main/Jenkins-userdata.sh | bash


--------------------------------------------------------------------------------------
- Configure Master and Clinet Configuration
---------------------------------------------------------------------------------------


NODE 1 : MAVEN 


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


--------------------------------------------------------------------------------
wait here
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
Host Key Verification Strategy: (Non Verifying Verification Strategy )

In (Prod), you don't do this, see how its done in the gradle setup


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



----------------------------------------------------------------------------------------------------------------------------------------------------

Our Maven Node is up but the diskspace where it is running is low so here is one of the option to sort that, we can either mount more space or disable or reduce the threshold for diskspace in Jenkins settings 


Option 3: Lower Jenkins Disk Space Threshold
You can configure Jenkins to accept lower disk space:

Go to Manage Jenkins → Nodes.

Click on the Maven-Build-Env node.

Click Configure.

Scroll down to Node Properties → Tool Locations or Environment Variables.

Check “Custom Workspace” or “Disk Space Monitoring” and adjust the threshold.

You can also disable disk space monitoring here.


---------------------------------------------------------------------------------


------------------------------------------------------------
setting up Gradle on Jenkins UI
------------------------------------------------------------


NOTE: Repeat the process for adding additional Nodes
3.2. Configure "Gradle-Build-Env"

NODE : 2

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

This shows that theres another config that overrides your main config and disables password authentication.


How to fix it:

Edit the file:


sudo nano /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

Change this line:


PasswordAuthentication no


to


PasswordAuthentication yes

Save and exit (Ctrl + O, Enter, Ctrl + X).

Restart ssh to apply changes:


sudo systemctl restart ssh

Verify the effective config again:


sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication'

It should now output:


permitrootlogin yes
passwordauthentication yes


Now try to SSH as root with password:


Test root SSH login from your terminal

ssh root@<GRADLE_VM_PUBLIC_IP>
 ------------------------------------------------------------------------------------------------

To shorten your GRADLE PATH  I.E the setting environment variables to tell any user  youre using to build with gradle where your gradle home is and the path to the gradle agent running the build, set Env variables like this :

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



---------------------------------------------------------------------------------------
Back to Jenkins web UI
-----------------------------------------------------------------------------


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

NOTE: Make sure the Agent Status shows Agent successfully connected and online in the Logs

NOTE: Repeat the process for adding any additional Nodes


--------------------------------------------------------------------

4️⃣ Plugin Installation Before Job Creation

Install: Delivery Pipeline plugin


5️⃣ CREATE PROJECT PIPELINE JOBS

5.1. Create Maven Build, Test and Deploy Job

-----------------------------------------------------------------------------
Maven Build Job
-----------------------------------------------------------------------------

Click on New Item

Name: Maven-Continuous-Integration-Pipeline-Build

Type: Freestyle

Click: OK

Select: GitHub project, Project url: YOUR_MAVEN_PROJECT_REPOSITORY      

(MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git )

Select Restrict where this project can be run:, 

Label Expression: Maven-Build-Env

Select Git, Repository URL: YOUR_MAVEN_PROJECT_REPOSITORY

(MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git )

Branches to build: Enter the branch in which your project codes are (*/main or master ) 

Mine :  */maven-sonarqube-nexus

Build Steps: Execute Shell

Command:  Now you need cd into whatever folder your pom.xml is in, check your repository and confirm if your pom.xml is in the root directory or in another directory in your project folder (paste these commands)

cd JavaWebApp  
mvn clean install

APPLY and SAVE

----------------------------------------------------------------------------------------------------------------------
Maven SonarQube Test Job
----------------------------------------------------------------------------------------------------------------
Click on New Item

Name: Maven-Continuous-Integration-Pipeline-SonarQube-Test

Type: Freestyle

Click: OK

- Select: GitHub project, Project url: YOUR_MAVEN_PROJECT_REPOSITORY

(MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git )

- Select Delivery pipeline configuration

stage Name: Test

Task Name : Run unit Test


Select Restrict where this project can be run:, Label Expression: Maven-Build-Env

Select Git, Repository URL: YOUR_MAVEN_PROJECT_REPOSITORY

(MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git )

Branches to build: */maven-sonarqube-nexus

Build Steps: Execute Shell

if we run the sonar build now, it will fail cos Maven 

set MAVEN_OPTS in your Jenkins Pipeline or Freestyle job build step
In the Execute shell build step or Pipeline sh step, prefix your Maven command:

PASTE THIS IN THE 'Command' section:

-----------------------------------------------------------------------------------
( My correct format )
---------------------------------------------------------------------------------------



cd JavaWebApp

export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED \
--add-opens java.base/java.util=ALL-UNNAMED \
--add-opens java.base/java.io=ALL-UNNAMED"

mvn sonar:sonar \
  -Dsonar.projectKey=Maven-JavaWebApp-Analysis \
  -Dsonar.host.url=http://172.31.5.118:9000 \
  -Dsonar.login=0049840b9b7777ccb5b196d6c4fd2896f04c1e4d


  
-----------------------------------------------------------------------------------------
THIS IS THE TEMPLATE USED ABOVE JUST FOR MORE CLARITY
-----------------------------------------------------------------------------------------    

mvn sonar:sonar \
  -Dsonar.projectKey=Maven-JavaWebApp-Analysis \
  -Dsonar.host.url=http://PROVIDE_PRIVATE_IP:9000 \
  -Dsonar.login=SONARQUBE_PROJECT_AUTHORIZATION_TOKEN

------------------------------------------------------------------------------------


APPLY and SAVE


-------------------------------------------------------------------------------------
Maven Nexus Upload Job
----------------------------------------------------------------------------------------

Click on New Item

Name: Maven-Continuous-Integration-Pipeline-Nexus-Upload

Type: Freestyle

Click: OK

Select: GitHub project, Project url: YOUR_MAVEN_PROJECT_REPOSITORY

(MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git )

- Select Delivery pipeline configuration

stage Name: Deploy

Task Name : Deploy to Env    ( Fill in your env either Prod, Dev etc )


Select Restrict where this project can be run:, Label Expression: Maven-Build-Env

Select Git, Repository URL: YOUR_MAVEN_PROJECT_REPOSITORY

 MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

Branches to build: */maven-sonarqube-nexus

Build Steps: Execute Shell

Command: 
--------------------------------------------------------------------------------------------
cd JavaWebApp
mvn clean deploy -X -s $SETTINGS_XML
---------------------------------------------------------------------------------------------
APPLY and SAVE

---------------------------------------------------------------------------------------------------------------------------------

Click on Dashboard on Jenkins

Click on The + (You'll see new view up there when you hover around the + sign beside 'All' on your Jenkins Dashboard. (Not the + beside 'New item' : The new Item is used to create a job but we want to create a view instead) 

Now Configure the View

Type : Delivery Pipeline view >> Components >> Click Add

scroll down and Select Enable start of new pipeline build

Name: Maven-Continuous-Integration-Pipeline or Gradle-Continuous-Integration-Pipeline

Initial Job: Select either the Maven Build Job or Gradle Build Job 

APPLY and SAVE

------------------------------------------------------------------------------------------------------------------------------------

5.2. Create Gradle Build, Test and Deploy Job
--------------------------------------------------------------------------------------------------------
Gradle Build Job
-----------------------------------------------------------------------------------------------------------

Click on New Item

Name: Gradle-Continuous-Integration-Pipeline-Build

Type: Freestyle

Click: OK

Select: GitHub project, Project url: YOUR_GRADLE_PROJECT_REPOSITORY

MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

Select Restrict where this project can be run:, Label Expression: Gradle-Build-Env

Select Git, Repository URL: YOUR_GRADLE_PROJECT_REPOSITORY

https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

Branches to build: */gradle-sonarqube-nexus-jenkins

Build Steps: Execute Shell

Command: 

export PATH=/opt/gradle/gradle-7.6.1/bin:$PATH
gradle clean build


APPLY and SAVE


--------------------------------------------------------------------------------------------------------------------------------
Integrating Sonarqube into your Gradle-Job.
-------------------------------------------------------------------------------------------------------------------------------- 


After launching your sonarqube instance

login into your sonarqube web ui

- Paste this on your web browser : SONARQUBE_PUBLIC_IP:9000

- initial admin username and password for sonarqube is 

username :admin

password : admin

- Create a new Project in sonarqube 

- click set up

-Generate a token e.g : Gradle-Build-Token       (Whatever name you want to use)

select Your project's main language   ( ours is java )

- select your build tool    (Gradle or maven) 



Look for the following piece of Code in the "build.gradle" config file

sonarqube {
    properties {
        property "sonar.sourceEncoding", "UTF-8"
                property "sonar.projectName", "PROJECT_NAME"
                property "sonar.host.url", "http://SONARQUBE_PRIVATE_IP:9000"
                property "sonar.login", "TOKEN_GENERATED"
    }
}

----------------------------------------------------------------------------------------------------------------

update it with the information Sonarqube populated for you in your "build.gradle" file in your project code.   


---------------------------------------------------------------------------------------------------------------------------
Note: DO NOT COPY THE WHOLE COMMANDS POPULATED BY SONARQUBE INTO YOUR BUILD.GRADLE FILE, USE THE TEMPLATE ABOVE AND EDIT IT  ( You only use the exact commands populated by sonarqube if you are using gradlew which means gradle wrapper. You do that when you do not install Gradle in the instance you are building with and, you are calling a stable version or a particular version of gradle during the build.)
---------------------------------------------------------------------------------------------------------------------------

Gradle SonarQube Test Job

Click on New Item

Name: Gradle-Continuous-Integration-Pipeline-SonarQube-Test

Type: Freestyle

Click: OK

Select: GitHub project, Project url: YOUR_GRADLE_PROJECT_REPOSITORY

MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

Select Restrict where this project can be run:, Label Expression: Gradle-Build-Env

Select Git, Repository URL: YOUR_GRADLE_PROJECT_REPOSITORY

Branches to build: */gradle-sonarqube-nexus-jenkins

Build Steps: Execute Shell

Command: 

export PATH=/opt/gradle/gradle-7.6.1/bin:$PATH
gradle sonarqube


APPLY and SAVE

-------------------------------------------------------------------------------------------------------------
INTEGRATING NEXUS INTO YOUR JENKINS PIPELINE
----------------------------------------------------------------------------------------------------

Create your Nexus Instance 

copy your Nexus_Instance_Public_IP:8081on web browser

username : admin

Get the admin password from your nexus instance

SSH into your nexus instance 

sudo cat /opt/sonatype-work/nexus3/admin.password

- you can change your password here but ensure to use same password in your "build.gradle" file in the Nexus block

Finish setting it up and disable anyonymous access

Create a new repo where your artifact would be deployed

Repo type: Maven2 (Hosted)

could either be snapshot or release depending on your project



Now push your changes to your repo after updating your sonarqube and Nexus details into your 'build.gradle' file

-----------------------------------------------------------------------------------------
Then download your project code into your Gradle instance 

---------------------------------------------------------------------------------------

for this project we will be cloning this repo 

git clone https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

-cd into project code 

cd realworld-cicd-pipeline-project

- check out to the branch you intend building 

- git checkout gradle-sonarqube-nexus-jenkins



-------------------------------------------------------------------------------------------
Gradle Nexus Deploy Job
-------------------------------------------------------------------------------------------

Click on New Item

Name: Gradle-Continuous-Integration-Pipeline-Nexus-Upload

Type: Freestyle

Click: OK

Select: GitHub project, Project url: YOUR_GRADLE_PROJECT_REPOSITORY

MY REPO URL:  https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git


Select Restrict where this project can be run:, Label Expression: Gradle-Build-Env

Select Git, Repository URL: YOUR_GRADLE_PROJECT_REPOSITORY

Branches to build: */gradle-sonarqube-nexus-jenkins     ( */your_project_branch)

Build Steps: Execute Shell

Command:

export PATH=/opt/gradle/gradle-7.6.1/bin:$PATH 
gradle publish

APPLY and SAVE

---------------------------------------------------------------------------

6️⃣ JOB INTEGRATION

6.1. Integrate The Maven JOBS Together To Create a CI Pipeline

Click on your First Job > Click Configure

Scroll to Post-build Actions Click Add P-B-A >> Select Build other projects >> Projects to build "Type out the name of your " Second Job

Click on your Second Job > Click Configure

Scroll to Post-build Actions Click Add P-B-A >> Select Build other projects >> Projects to build "Type out the name of your "Select" Third Job

-----------------------------------------------------------------------------------------------------------------------------------

6.2. Integrate The Gradle JOBS Together To Create a CI Pipeline

Click on your First Job > Click Configure

Scroll to Post-build Actions Click Add P-B-A >> Select Build other projects >> Projects to build "Type out the name of your "Select" Second Job

Click on your Second Job > Click Configure

Scroll to Post-build Actions Click Add P-B-A >> Select Build other projects >> Projects to build "Type out the name of your "Select" Third Job


After updating the settings.xml file and the pom.xml files, and pushing to your repo, 

--------------------------------------------------------------------------------------------------------------------------
Now go clone your project code into your Maven instance and Cd into the branch you have your code ( In your maven instance )
-----------------------------------------------------------------------------------------------------------------------------


The Deploy job is still failing due to credentials failure so we need to configure manually in the Jenkins UI which settings.xml file Maven should pick up

here are the steps:

1. Verify Jenkins Maven Credentials Injection Setup
a) Create a credentials Specifically for Nexus and Store in Jenkins:
Go to Jenkins → Manage Jenkins → Credentials → System → Global credentials.

Click Add Credentials:

Kind: Username with password

Username: your Nexus username (In Enterprise settings, the Nexus accounts will have different users and you will be given a username and password, ensure the username and password your admin gives you have the right permission privilege)

Password: your Nexus password

ID: nexus-creds (or any ID you like)

Save.

b) Configure your Jenkins job to inject these credentials:
Go back to the Nexus Deploy job configuration:
----------------------------------------------------------------------------------------
Go to your Jenkins dashboard.

Click on your freestyle job’s name. ( i.e Nexus Upload Job)

Click Configure on the left sidebar.

Scroll down the configuration page — you’ll see sections like:


-----------------------------------------------------------------------------------------------------
General

Source Code Management

Build Triggers

Build Environment ←  ( This is what you're looking for)

Build

Post-build Actions
--------------------------------------------------------------------------------------------------------



Under Build Environment, check Use secret text(s) or file(s).

Click Add Binding → Username and password (separated).


Set Username Variable: NEXUS_USERNAME

Set Password Variable: NEXUS_PASSWORD

Credentials : select Specific Credentials 

Click the drop down and select your Nexus credential  ( nexus-creds )

c) Use a managed Maven settings.xml file with variables:

First, Install Config File Provider Plugin (if not already).

Go to plugins under Manage Jenkins and install the 'Config File Provider' Plugin and refresh Jenkins

Next

Go to Manage Jenkins → Managed files → Add a new Config →  Select Maven settings.xml.

Paste in ID section :  maven-settings-nexus

Create a settings.xml. Paste this:


<settings>
  <servers>
    <server>
      <id>nexusdeploymentrepo</id>
      <username>${env.NEXUS_USERNAME}</username>
      <password>${env.NEXUS_PASSWORD}</password>
    </server>
  </servers>
</settings>




d) In your Nexus upload job, 

Under build step select 'Add build step'

Select : Provide Configuration files

--------------------------------------------------------------------------------------------
 After selecting Provide Configuration files, You'd see Managed Files :

File : maven-settings-nexus  ( select whatever name you set as your settings file, from the drop down )

Target : settings.xml

Variable : SETTINGS_XML      ( NOTE : MUST BE IN CAPITAL LETTERS )


e) Configure the Nexus-Upload Job to use the settings.xml file you just configured in the Jenkins UI to publish the Artifact to nexus 


Step by Step
-------------------------------------------------------------------------------------------------------------------------------
Select Nexus Upload Job

select  configuration, 

Scroll down to Build Steps section

Select Add build step, specify Settings file to use the provided one.

Under build steps section :  select 'Add build step'

- Paste this in the 'Command' section : 

-------------------------------------------------------------------------------------------------------------

cd JavaWebApp
mvn clean deploy -X -s $SETTINGS_XML

--------------------------------------------------------------------------------------------------------------------

Note: The -X helps Maven to run in debug mode and output detailed logs about what it’s doing — including info about authentication, repository access, plugin execution, etc.

This extra detail helps diagnose why deploys fail or why credentials aren’t working.


7️⃣ TEST YOUR PIPELINE


It is best practice to use environment variables instead of hardcoding secrets in our build.gradle file or Jenkins file So we can either set environment variable on Jenkins UI ( either on Jenkins global configuration applies to all Jenkins job or on a particular node. I.e jobs running on a particular node will use that environment variable or on the job itself) 

You can also set environment variable inside the instance (i.e using 'expose' but its not best practice as your logs of your nodes node might get into the wrong hand but you can use the Jenkins Credential plug in to use the environment variables)
GRADLE BUILD THAT READ ENVIRONMENT SETTINGS FROM JENKINS 

Here's a complete build.gradle example that reads Jenkins environment variables (set via Jenkins UI in your master-client setup) using variables, keeping secrets out of your code:

sample of my "build.gradle" file   (Also in my repo )




-----------------------------------------------------------------------------


plugins {
    id 'java'
    id 'org.springframework.boot' version '3.1.0'
    id 'io.spring.dependency-management' version '1.1.0'
    id 'org.sonarqube' version '4.3.0.3225'
    id 'maven-publish'
}

def sonarToken = System.getenv('SONAR_TOKEN') ?: ''
def nexusUsername = System.getenv('NEXUS_USERNAME') ?: ''
def nexusPassword = System.getenv('NEXUS_PASSWORD') ?: ''

group = 'com.example'
version = '1.0.0-SNAPSHOT'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

sonarqube {
    properties {
        property "sonar.sourceEncoding", "UTF-8"
        property "sonar.projectName", "Gradle-Build"
        property "sonar.projectKey", "Gradle-Build"
        property "sonar.host.url", "http://172.31.2.62:9000"
        property "sonar.login", sonarToken
    }
}

publishing {
    publications {
        maven(MavenPublication) {
            groupId = project.group
            artifactId = 'your-artifact-id'
            version = project.version
            artifact(tasks.bootJar)
        }
    }
    repositories {
        maven {
            url = uri("http://172.31.14.16:8081/repository/Gradle-Artifact/")
            allowInsecureProtocol = true
            credentials {
                username = nexusUsername
                password = nexusPassword
            }
        }
    }
}

test {
    useJUnitPlatform()
}

tasks.withType(PublishToMavenRepository) {
    doFirst {
        println 'Publishing artifacts to Nexus...'
        println "Using Nexus username: ${nexusUsername ? '****' : 'NOT SET'}"
        println "Using Sonar token: ${sonarToken ? '****' : 'NOT SET'}"
    }
}



-------------------------------------------------------------------------------


THINGS TO NOTE : 

Most Jobs are snapshot and are updates to previous Apps, and it is important to specify  in the build.gradle if its a release or snapshot version. You set this in the version section a shown below :


--------------------------------------------------------------------------------------------------

group = 'com.example'
version = '1.0.0'
sourceCompatibility = '17'

--------------------------------------------------------------------------------------------------



If you do not specify like in the column below, gradle will assume its a 'RELEASE' version if its a snapshot version of your app, make sure to specify like this:


------------------------------------------------------------------------------------------------------

group = 'com.example'
version = '1.0.0-SNAPSHOT'
sourceCompatibility = '17'

-------------------------------------------------------------------------------------------------
This method below sets environment variable only at the level of the job and when you print your logs and echo it, you can still see the credentials, which can expose your credentials.
----------------------------------------------------------------------------------------------

How to set environment variables in Jenkins UI:
Go to your Jenkins job → Configure → Build Environment section.

Check “Use secret text(s) or file(s)” or “Inject environment variables” (depending on plugins installed).

Add the following environment variables (using Jenkins credentials plugin for secrets is recommended):

SONAR_TOKEN — paste your SonarQube token

NEXUS_USERNAME — paste your Nexus username

NEXUS_PASSWORD — paste your Nexus password

These will be available as environment variables during the build, so build.gradle will pick them up automatically.



---------------------------------------------------------------------------------------------------
BELOW IS THE THE RECOMMENDED MEHTOD FOR OUR PROJECT SINCE IT IS A FREESTYLE PROJECT
------------------------------------------------------------------------------------------------------
For Freestyle Jobs with Credentials Binding:
Add your secrets to Jenkins Credentials Store:

Go to Jenkins Dashboard > Manage Jenkins > Credentials > System > Global credentials (unrestricted) > Add Credentials ( on the left sidebar.)

Choose the Kind of credential you want to add:

Secret text — For tokens like SonarQube token.

Username with password — For Nexus or any service requiring username + password.

Give them meaningful IDs, e.g., nexus-creds and sonar-token.

Bind credentials to environment variables in your job config:

---------------------------------------------------------------------------------------------
Do this for your sonarqube job
---------------------------------------------------------------------------------------------

- Open your Freestyle job’s configuration page. 
select your job
select configure

- Scroll down to Build Environment section.

Check “Use secret text(s) or file(s)” or “Credentials Binding” (depending on your plugin version).

select 'Add bindings':

For Nexus, bind the username/password credential:

Choose Username and password (separated) binding.

Assign variables, e.g., NEXUS_USERNAME and NEXUS_PASSWORD.

Select the credential ID nexus-creds.




--------------------------------------------------------------------------------------------------
Do this for your sonarqube job
---------------------------------------------------------------------------------------------------


For Sonar token, bind the Secret text credential:

Assign variable SONAR_TOKEN.

Select the credential ID sonar-token.

Now when Jenkins runs the build, it injects those environment variables securely.







------------------------------------------------------------------------------------------------------

ALTHOUGH OUR PROJECT IS A FREESTYLE JOB IF YOU WANT TO USE A DECLARATIVE APPROACH USING A JENKINSFILE THIS IS A TEMPLATE OF JENKINSFILE YOU WILL USE 
-----------------------------------------------------------------------------------------------------

pipeline {
    agent any

    environment {
        SONAR_TOKEN    = credentials('sonarqube-token-id')    // Jenkins credential ID for Sonar token
        NEXUS_USERNAME = credentials('nexus-username-id')     // Jenkins credential ID for Nexus username
        NEXUS_PASSWORD = credentials('nexus-password-id')     // Jenkins credential ID for Nexus password
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh './gradlew clean build test'
            }
        }

        stage('Publish Artifacts') {
            steps {
                sh './gradlew publish'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh './gradlew sonarqube'
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
        success {
            echo 'Build, publish, and SonarQube analysis completed successfully!'
        }
        failure {
            echo 'Build or analysis failed. Please check the logs.'
        }
    }
}

-------------------------------------------------------------------------------------------------

How this works:
Uses Jenkins credentials() to inject secrets securely.

'build.gradle' accesses these via System.getenv(...) as shown earlier.

Runs stages for checkout, build, publish, and SonarQube analysis separately.

Cleans workspace after each run.

Masks secrets in console output automatically.

Make sure:

The Jenkins credentials IDs (sonarqube-token-id, nexus-username-id, nexus-password-id) match your Jenkins setup.

Your build.gradle is configured to read those environment variables.