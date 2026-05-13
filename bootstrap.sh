#!/bin/bash

set -e
echo "Setting up Serverless Resume Platform..."

if ! command -v aws &> /dev/null; then
    echo "AWS CLI not installed. Please install it first."
    exit 1
fi
echo "AWS CLI found"

if ! command -v terraform &> /dev/null; then
    echo "Terraform not installed."
    exit 1
fi
echo "Terraform found"

echo "Setting up Terraform remote state..."
cd terraform/backend-setup
terraform init
terraform apply -auto-approve
cd ../..

echo "Deploying main infrastructure..."
cd terraform
terraform init
terraform apply -auto-approve
cd ..
echo " Setup complete!"