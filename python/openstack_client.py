#!/usr/bin/env python
#encoding=utf8

from openstackclient.identity.client import identity_client_v2
from keystoneclient import session as identity_session
import glanceclient
import novaclient.client as novaclient
import cinderclient.client as cinderclient

# 定义 project_client version
NOVA_CLI_VER = 2
GLANCE_CLI_VER = 2
CINDER_CLI_VER = 2


class OpenstackClients(object):
    """Clients generator of openstack."""

    def __init__(self, auth_url, username, password, tenant_name):

        ### Identity authentication via keystone v2
        # An authentication plugin to authenticate the session with.
        # 通过身份验证信息获取 keystone 的 auth object
        # Keystoneclient v2 的详细使用介绍请浏览 https://docs.openstack.org/developer/python-keystoneclient/using-api-v2.html
        auth = identity_client_v2.v2_auth.Password(
            auth_url=auth_url,          # http://200.21.18.3:35357/v2.0/
            username=username,          # admin
            password=password,          # fanguiju
            tenant_name=tenant_name)    # admin
        try:
            # 通过 auth object 获取 Keystone 的 session object
            self.session = identity_session.Session(auth=auth)
        except Exception as err:
            raise

        # Return a token as provided by the auth plugin.
        # 通过 session object 获取 Tenant token
        self.token = self.session.get_token()

    def get_glance_client(self, interface='public'):
        """Get the glance-client object."""

        # Get an endpoint as provided by the auth plugin.
        # 默认获取 glance project 的 public endpoint
        glance_endpoint = self.session.get_endpoint(service_type="image",
                                                    interface=interface)
        # Client for the OpenStack Images API.
        # 通过 glance endpoint 和 token 获取 glance_client object
        # 然后就可以使用 glance_client 调用其实例方法来实现对 glance project 的操作了
        # glanceclient v2 所提供的实例方法列表请浏览 https://docs.openstack.org/developer/python-glanceclient/ref/v2/images.html
        glance_client = glanceclient.Client(GLANCE_CLI_VER,
                                            endpoint=glance_endpoint,
                                            token=self.token)
        return glance_client

    def get_nova_client(self):
        """Get the nova-client object."""

        # Initialize client object based on given version. Don't need endpoint.
        # 也可以 不指定 endpoint 的类型, 仅使用 session object 来获取 nove_client
        # novaclient v2 的实例方法列表请浏览 https://docs.openstack.org/developer/python-novaclient/api.html#usage 
        nova_client = novaclient.Client(NOVA_CLI_VER, session=self.session)
        return nova_client

    def get_cinder_client(self, interface='public'):
        """Get the cinder-client object."""

        cinder_endpoint = self.session.get_endpoint(service_type='volume',
                                                    interface=interface)
        # cinder_client v2 的实例方法列表请查看 https://docs.openstack.org/developer/python-cinderclient/
        cinder_client = cinderclient.Client(CINDER_CLI_VER, session=self.session)
        return cinder_client

