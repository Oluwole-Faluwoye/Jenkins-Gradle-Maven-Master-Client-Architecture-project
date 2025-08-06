#!/bin/bash

echo "=============================="
echo "🚀 Installing Java 17 and Maven"
echo "=============================="

# Ask if Java 17 should be installed
read -p "Do you want to install Java 17? [Y/n]: " install_java
install_java=${install_java:-Y}

if [[ "$install_java" =~ ^[Yy]$ ]]; then
  echo "Installing Java 17..."
  sudo yum install -y java-17-amazon-corretto-devel || sudo yum install -y java-17-openjdk-devel
else
  echo "Skipping Java installation."
fi

# Check Java installation
echo "Checking Java..."
java -version || echo "⚠️ Java not found after install"

# Ask if Maven should be installed
read -p "Do you want to install Maven? [Y/n]: " install_maven
install_maven=${install_maven:-Y}

if [[ "$install_maven" =~ ^[Yy]$ ]]; then
  echo "Installing Maven..."
  MAVEN_VERSION=3.9.6
  wget https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip -P /tmp
  sudo unzip -q /tmp/apache-maven-${MAVEN_VERSION}-bin.zip -d /opt
  sudo mv /opt/apache-maven-${MAVEN_VERSION} /opt/maven
else
  echo "Skipping Maven installation."
fi

# Ask to configure .bash_profile
read -p "Do you want to update your .bash_profile with JAVA_HOME and M2_HOME? [Y/n]: " update_profile
update_profile=${update_profile:-Y}

if [[ "$update_profile" =~ ^[Yy]$ ]]; then
  JAVA_HOME_PATH=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
  echo "Setting JAVA_HOME to $JAVA_HOME_PATH"
  
  echo "Updating ~/.bash_profile ..."
  {
    echo ""
    echo "# Java and Maven environment variables"
    echo "export JAVA_HOME=$JAVA_HOME_PATH"
    echo "export M2_HOME=/opt/maven"
    echo "export PATH=\$JAVA_HOME/bin:\$M2_HOME/bin:\$PATH"
  } >> ~/.bash_profile

  echo "Reloading ~/.bash_profile..."
  source ~/.bash_profile
else
  echo "Skipping profile update."
fi

# Final checks
echo "=============================="
echo "✅ Final Checks"
echo "=============================="
echo "Java Version:"
java -version

echo ""
echo "Maven Version:"
mvn -v || echo "⚠️ Maven command not found. Check if PATH is set correctly."

echo "✅ Done!"













# 4. Set environment variables globally (for all users)
read -p "Do you want to set JAVA_HOME and M2_HOME globally for all users? [Y/n]: " global_env
global_env=${global_env:-Y}

if [[ "$global_env" =~ ^[Yy]$ ]]; then
  JAVA_HOME_PATH=$(dirname $(dirname $(readlink $(readlink $(which javac)))))

  echo "Setting global environment variables..."

  sudo tee /etc/profile.d/java_maven.sh > /dev/null <<EOF
# Java and Maven environment variables
export JAVA_HOME=$JAVA_HOME_PATH
export M2_HOME=/opt/maven
export PATH=\$JAVA_HOME/bin:\$M2_HOME/bin:\$PATH
EOF

  sudo chmod +x /etc/profile.d/java_maven.sh
  echo "Environment variables set in /etc/profile.d/java_maven.sh"
  source /etc/profile.d/java_maven.sh
else
  echo "Skipping global environment update."
fi

# 5. Create Jenkins user
read -p "Do you want to create the 'jenkinsmaster' user? [Y/n]: " create_user
create_user=${create_user:-Y}

if [[ "$create_user" =~ ^[Yy]$ ]]; then
  read -sp "Enter password for jenkinsmaster user: " jenkins_password
  echo
  sudo useradd -m jenkinsmaster
  echo "jenkinsmaster:$jenkins_password" | sudo chpasswd
  echo "User 'jenkinsmaster' created."

  # Copy the environment config to jenkinsmaster
  sudo cp /etc/profile.d/java_maven.sh /home/jenkinsmaster/
  echo "source /home/jenkinsmaster/java_maven.sh" | sudo tee -a /home/jenkinsmaster/.bash_profile
  sudo chown jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.bash_profile /home/jenkinsmaster/java_maven.sh
else
  echo "Skipping user creation."
fi

# 6. Final checks
echo "=============================="
echo "✅ Final Checks"
echo "=============================="
echo "Java Version:"
java -version

echo ""
echo "Maven Version:"
mvn -v || echo "⚠️ Maven command not found. Check PATH."

echo ""
echo "✅ Script Completed Successfully!"







Now FOLLOW THESE STEPS 

# 1. Create the script file
nano install-java17-maven.sh

# 2. Paste the entire script above into the file

# 3. Save and exit (Ctrl + O, Enter, then Ctrl + X)

# 4. Make it executable
chmod +x install-java17-maven.sh

# 5. Run it interactively
./install-java17-maven.sh
