#!/bin/bash
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel.x86_64 wget
cd /opt/
sudo wget http://mirrors.fibergrid.in/apache/tomcat/tomcat-8/v8.5.34/bin/apache-tomcat-8.5.34.tar.gz
sudo tar -xvzf apache-tomcat-8.5.34.tar.gz
sudo rm -rf apache-tomcat-8.5.34.tar.gz
sudo mv apache-tomcat-8.5.34 tomcat8
sudo chown -R ec2-user:ec2-user /opt/tomcat8
/opt/tomcat8/bin/startup.sh
sudo chown -R ec2-user:ec2-user /opt/tomcat8
