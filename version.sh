# This file is sourced to set various values used in the build process.

# This is the version of this packer-ibmcloud container.
VERSION=1.0.9

# These two vars specify the base URL and version of the base
# packer container.
PACKER_CONTAINER_URL=hashicorp/packer
PACKER_CONTAINER_VERSION=latest

# This is the version of the IBM Packer plugin and the SHA256 checksum
PLUGIN_GIT_URL=https://github.com/IBM/packer-plugin-ibmcloud/releases/download
PLUGIN_VERSION=1.0.1
PLUGIN_SHA=ba209eaafb1d1808111f90ddab75e95673aabb02125d53e1a97f7af3752368e4
