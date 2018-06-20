#!/usr/bin/env python
#encoding=utf8

import os
import openstack_client

if __name__ == '__main__':
    cbts-client = OpenstackClients(os.environ['OS_AUTH_URL'], os.environ['OS_USERNAME'], os.environ['OS_PASSWORD'], os.environ['OS_TENANT_NAME'])
    images = cbts-client.cbts-client()
