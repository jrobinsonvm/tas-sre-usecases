FROM quay.io/eduk8s/jdk8-environment:master
USER root
RUN sudo yum update -y && yum install wget -y 
RUN sudo wget -O /etc/yum.repos.d/cloudfoundry-cli.repo https://packages.cloudfoundry.org/fedora/cloudfoundry-cli.repo
RUN sudo yum install cf-cli -y 
USER 1001
