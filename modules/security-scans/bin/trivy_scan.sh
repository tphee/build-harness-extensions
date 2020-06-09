#!/bin/bash

set -e

IMAGE=$1

if [[ -z "$IMAGE" ]]
then
  echo "IMAGE not set. Skipping image scan."
  exit 0
fi

sudo apt-get install alien
sudo alien -i package_file.rpm
sudo alien package_file.rpm
sudo dpkg -i package_file.deb


curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b .

if [[ -x ./trivy ]]
then
  ./trivy --version
  echo "Starting to scan image: ${IMAGE}"
  ./trivy image --ignore-unfixed --exit-code 1 ${IMAGE}
  if [ $? -eq 1 ]
  then
    echo "ERROR: Image scan failed!"
    exit 1
  else
    echo "Image scan passed"
  fi
else
  echo "Trivy tool failed to install.  Skipping image scan."
fi	
