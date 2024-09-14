# Store the aws Access key and secret access key in jenkins secret text 
# give the jenkins user access permission to run the scripts or add all the jenkins users in the  sudoers permission 
  sudo visudo
  jenkins ALL=(ALL) NOPASSWD:ALL # this will not recommended due to security issue
#  I have directly hard coded here everything for security purpose will  use var.tf 
#  here i have used sample static templete 
#  here i haven't done any code test if we want we can use after docker image build stage in pipline using sonar scanner 
#  sonar scanner we can create separate server and use docker compose
#  kindly Check your CI server's installed commands particullary UNZIP or else you need to install " apt install unzip "
