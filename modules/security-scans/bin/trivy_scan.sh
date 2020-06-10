#!/bin/bash

IMAGE=$1

if [[ -z "$IMAGE" ]]
then
  echo "IMAGE not set. Skipping image scans"
  exit 0
fi

echo "Installing rpm"
sudo add-apt-repository universe > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install rpm > /dev/null

echo "Installing trivy image scanning tool"
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin > /dev/null

if [[ -x /usr/local/bin/trivy ]]
then
  /usr/local/bin/trivy --version
  echo "Starting to scan image: ${IMAGE}"
  /usr/local/bin/trivy image --ignore-unfixed --exit-code 1 ${IMAGE}
  if [ $? -eq 1 ]
  then
    echo "Error: Image scans failed!"
    exit 1
  else
    echo "Image scans passed"
  fi
else
  echo "Trivy tool failed to install.  Skipping image scans"
fi	
