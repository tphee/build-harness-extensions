#!/bin/bash

set -e

IMAGE=$1

if [[ -z "$IMAGE" ]]
then
  echo "IMAGE not set. Skipping image scan."
  exit 0
fi

export TRIVY_VERSION=$(curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
tar zxvf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz

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
