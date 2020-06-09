#!/bin/bash

# set -e

IMAGE=$1

if [[ -z "$IMAGE" ]]
then
  echo "IMAGE not set. Skipping image scan."
  exit 0
fi

echo "Installing rpm"
sudo add-apt-repository universe > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install rpm > /dev/null

echo "Installing trivy"
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b . > /dev/null

if [[ -x ./trivy ]]
then
  ./trivy --version
  echo "Starting to scan image: ${IMAGE}"
  ./trivy image --ignore-unfixed --exit-code 1 ${IMAGE}
  if [ $? -eq 1 ]
  then
    echo "Error: Image scan failed!"
    exit 1
  else
    echo "Image scan passed"
  fi
else
  echo "Trivy tool failed to install.  Skipping image scan."
fi	
