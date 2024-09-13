#!/bin/bash

# Download Terraform
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip

# Unzip and install
unzip terraform_1.5.7_linux_amd64.zip
chmod +x terraform
mv terraform /usr/local/bin/

# Clean up
rm terraform_1.5.7_linux_amd64.zip

# Verify installation
terraform --version
