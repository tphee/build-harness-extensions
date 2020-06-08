# Full path to this modules' scripts directory.
SECURITYSCANS_DIR=${BUILD_HARNESS_PATH}/../build-harness-extensions/modules/security-scans/scripts

# Find component name and component version from repo artifacts
SECURITYSCANS_IMAGE_NAME ?= $(shell cat ${BUILD_HARNESS_PATH}/../COMPONENT_NAME 2> /dev/null)
SECURITYSCANS_IMAGE_VERSION ?= $(shell cat ${BUILD_HARNESS_PATH}/../COMPONENT_VERSION 2> /dev/null)
SECURITYSCANS_IMAGE_TAG_EXTENSION ?= ${COMPONENT_TAG_EXTENSION}

# Build the details for the remote destination repo for the image
SECURITYSCANS_DOCKER_REPO ?= "quay.io/open-cluster-management"

# List of pattern to scan in the image
SECURITYSCANS_PATTERNS ?= "password;_pwd;pw;credential;secret;signature;token;key;[\d|a-z]{40}@;=[\d|a-z]{40,64};\"[\d|a-z]{40,64}\""

# trivy 
SECURITYSCANS_TRIVY_INSTALL_COMMAND ?= "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin"
SECURITYSCANS_TRIVY ?= "/usr/local/bin/trivy"

.PHONY: security/scans configscan/report imagescan/status

## Scan the image config to find potential leaked credentials
configscan/report:
	@$(call assert-set,SECURITYSCANS_IMAGE_NAME)
	@$(call assert-set,SECURITYSCANS_IMAGE_VERSION)
	@python3 $(SECURITYSCANS_DIR)/configscan.py --image $(SECURITYSCANS_DOCKER_REPO)/$(SECURITYSCANS_IMAGE_NAME):$(SECURITYSCANS_IMAGE_VERSION)$(SECURITYSCANS_IMAGE_TAG_EXTENSION) --patterns $(SECURITYSCANS_PATTERNS)

## Check the image scan status
imagescan/status:
	@$(call assert-set,SECURITYSCANS_IMAGE_NAME)
	@$(call assert-set,SECURITYSCANS_IMAGE_VERSION)
	@( \
		#if [[ ! -z "$(shell echo $(TRAVIS_BRANCH) | grep ^release-[0-9][0-9]*\..*$ )" ]]; then \
		$(SECURITYSCANS_TRIVY_INSTALL_COMMAND); \
		if [ -x $(SECURITYSCANS_TRIVY) ]; then \
			$(SECURITYSCANS_TRIVY) image --ignore-unfixed --exit-code 1 ${SECURITYSCANS_DOCKER_REPO}/${SECURITYSCANS_IMAGE_NAME}:${SECURITYSCANS_IMAGE_VERSION}${SECURITYSCANS_IMAGE_TAG_EXTENSION}; \
			if [ $? -eq 1 ]; then \
				echo "Image scan failed"; \
				exit 1; \
			else \
				echo "Image scan passed"; \
			fi; \
		else \
			echo "Trivy image scan tool failed to install.  No image scan this time" \
		fi; \
		#fi;
	)

## Run all security scans
security/scans: %security/scans: %configscan/report %imagescan/status
