#!/usr/bin/env bash

# To use an OpenStack cloud you need to authenticate against the Identity
# service named keystone, which returns a **Token** and **Service Catalog**.
# The catalog contains the endpoints for all services the user/tenant has
# access to - such as Compute, Image Service, Identity, Object Storage, Block
# Storage, and Networking (code-named nova, glance, keystone, swift,
# cinder, and neutron).
#
# *NOTE*: Using the 2.0 *Identity API* does not necessarily mean any other
# OpenStack API is version 2.0. For example, your cloud provider may implement
# Image API v1.1, Block Storage API v2, and Compute API v2.0. OS_AUTH_URL is
# only for the Identity API served through keystone.
export OS_AUTH_URL=http://hz-dc-os-ohn-12.eecloud.nsn-net.net:5000

# With the addition of Keystone we have standardized on the term **tenant**
# as the entity that owns the resources.
export OS_TENANT_ID=31b2c240c7f24988a42f0700d355831c
export OS_TENANT_NAME="ca-hzcbtsscm"

# unsetting v3 items in case set
unset OS_PROJECT_ID
unset OS_PROJECT_NAME
unset OS_USER_DOMAIN_NAME
unset OS_INTERFACE

# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
export OS_USERNAME="ca-hzcbtsscm"

# With Keystone you pass the keystone password.
# echo "Please enter your OpenStack Password for project $OS_TENANT_NAME as user $OS_USERNAME: "
# read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=$(grep passwd ~/.openstack_passwd | awk -F = '{print $2}')

# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="RegionOne"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi

export OS_ENDPOINT_TYPE=publicURL
export OS_IDENTITY_API_VERSION=2

export env_image="90fd2729-24e1-4f66-a8d1-3b7fca6fabd5"
export env_key="hz-ohn-12"
export env_flavor="el.052-0317"
export env_net="4bcec95a-9701-4068-95f1-c739a6ff1a03"
