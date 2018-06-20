#!/usr/bin/env bash
# set -e
IFS=$' \t\n'

location=XXX

if [ -z "$location" ];then
    echo "arguments error;need -L HZ/ESPOO"
    exit 2
fi

unset http_proxy
export http_proxy=http://10.144.1.10:8080
unset https_proxy
export https_proxy=https://10.144.1.10:8080

if [ -h "/usr/bin/python" ];then rm -rf /usr/bin/python_bak;mv -f /usr/bin/python /usr/bin/python_bak;fi
ln -s /usr/bin/python2 /usr/bin/python

if ! which python3;then
    echo install python34
    yum install -y python34
    if ! which python3 >/dev/null 2>&1;then
        echo install python3 failed >error.log
    fi
fi

pkg_list="java-1.8.0-openjdk java-1.8.0-openjdk-devel svn patch s3cmd openssl perl-Archive-Zip glibc cmake3 gcc-c++ git git-lfs compat-expat1 libguestfs libguestfs-bash-completion.noarch python34-pip.noarch python2-pip.noarch cifs cifs-utils.x86_64 tree dos2unix symlinks lvm2"
for pkg in $pkg_list;do
    echo -----------------------install $pkg-------------------------------
    yum  install -y $pkg
    if [ $? -ne 0 ];then
        echo install $pkg failed >error.log
    fi
    sleep 3s
done

# git2 have some difference with normal packages
yum install -y rh-git29
cp -f /opt/rh/rh-git29/root/usr/bin/* /usr/bin/

service libvirtd restart || echo restart libvirtd failed >error.log

chmod 777 -R /run/user/
ln -s /usr/bin/cmake3 /usr/bin/cmake

pip3 install -i https://pypi.cb.scm.nsn-rdnet.net/pypi/  requests ftputil boto log_parser pysmb local-ltesdkroot configparser
pip3 install boto filechunkio six lxml configparser git-repo
pip install configparser
pip3 install setuptools --upgrade
pip3 install git+https://gerrite1.ext.net.nokia.com:443/scm_tools
pip3 install --upgrade python-openstackclient

mkdir -p /build/ltesdkroot  /build/rcp /mnt/CBTS_ESPOO /mnt/CBTS_HZ /var/fpwork
chmod 777 -R /var/fpwork

echo "export SVN_EDITOR=vim" >>/root/.bashrc

# svn export https://beisop60.china.nsn-net.net/isource/svnroot/hz_hetran_scm/CBTS/scripts/ee_cloud/ldap.sh .
yum install autofs -y
systemctl enable autofs
echo "/home     /etc/auto.home" >>/etc/auto.master 
echo "*       -fstype=nfs,rw,soft,intr,rsize=32768,wsize=32768        hzlinn12.china.nsn-net.net:/hzlinn12_home/home/&" >/etc/auto.home
systemctl restart autofs

yum install ypbind -y

echo "# primary NIS servers" >> /etc/yp.conf
echo "domain eelinnis.emea.nsn-net.net server hzlina10.china.nsn-net.net"  >> /etc/yp.conf
echo "# backup NIS servers" >> /etc/yp.conf
echo "domain eelinnis.emea.nsn-net.net server belina10.china.nsn-net.net" >> /etc/yp.conf
echo "domain eelinnis.emea.nsn-net.net server cdlina10.china.nsn-net.net" >> /etc/yp.conf

#svn export https://beisop60.china.nsn-net.net/isource/svnroot/hz_hetran_scm/CBTS/scripts/ee_cloud/nsswitch.conf /etc/nsswitch.conf --force
systemctl enable ypbind
systemctl start ypbind
useradd  -u 99000739 -g 0 --password awUczpsPEf2A6 -d /home/ca_hzcbtsscm ca_hzcbtsscm

yum install openldap-clients nss-pam-ldapd pam_ldap -y
echo "URI ldap://ed-p-gl.emea.nsn-net.net:389" >> /etc/openldap/ldap.conf
echo "BASE ou=People, o=NSN" >> /etc/openldap/ldap.conf
authconfig --enableldap --enableldapauth --ldapserver='ldap://ed-p-gl.emea.nsn-net.net:389' --ldapbasedn='ou=People, o=NSN' --enableshadow --enablelocauthorize --passalgo=sha256 --update
systemctl restart nslcd
sed -i 's#^PasswordAuthentication.*#PasswordAuthentication yes#g' /etc/ssh/sshd_config
sed -i 's#^ChallengeResponseAuthentication.*#ChallengeResponseAuthentication yes#g' /etc/ssh/sshd_config
systemctl restart sshd

## give ca_hzcbtsscm sudo permission
sed -i '93a\ca_hzcbtsscm ALL=(ALL)  ALL\nca_hzcbtsscm ALL = NOPASSWD: ALL' /etc/sudoers

if [ "$location" = "HZ" ];then
    if ! cat /etc/fstab | grep "/build/ltesdkroot";then
        echo "hzchon11.china.nsn-net.net:/vol/hzchon11_ltesdk/ltesdkroot/ltesdkroot /build/ltesdkroot nfs soft,intr,retry=1,rw,rsize=32768,wsize=32768 0 0" >>/etc/fstab
    fi
    if ! cat /etc/fstab | grep "/build/rcp";then
        echo "hzchon10.china.nsn-net.net:/vol/hzchon10_ltesdkrcp_bin /build/rcp nfs soft,intr,retry=1,rw,rsize=32768,wsize=32768 0 0" >>/etc/fstab
    fi
elif [ "$location" = "ESPOO" ];then
    if ! cat /etc/fstab | grep "/build/ltesdkroot";then
        echo "eslinn11.emea.nsn-net.net:/vol/eslinn11_ltesdk/build/build/ltesdkroot /build/ltesdkroot nfs soft,intr,retry=1,rw,rsize=32768,wsize=32768 0 0" >>/etc/fstab
    fi
    if ! cat /etc/fstab | grep "/build/rcp";then
        echo "eslinn10.emea.nsn-net.net:/vol/eslinn10_ltesdkrcp_bin/rcp /build/rcp nfs soft,intr,retry=1,rw,rsize=32768,wsize=32768 0 0" >>/etc/fstab
    fi
else
    echo arguments error
    exit 2
fi

if ! cat /etc/fstab | grep "/mnt/CBTS_ESPOO";then
    echo "//87.254.221.45/CBTS_release                            /mnt/CBTS_ESPOO     cifs username=cbts,password=Panda123#,uid=ca_hzcbtsscm,sec=ntlm,file_mode=0644,dir_mode=0755" >>/etc/fstab
fi
if ! cat /etc/fstab | grep "/mnt/CBTS_HZ";then
    echo "//hzeefsn12.china.nsn-net.net/CBTS_release     /mnt/CBTS_HZ     cifs sec=ntlm,username=cbts,password=Panda123#,uid=ca_hzcbtsscm,file_mode=0644,dir_mode=0755" >>/etc/fstab
fi
mount -a
if [ $? -ne 0 ];then
    echo mount failed >error.log
fi

if [ "$location" = "HZ" ];then
    if ! hostname | grep hz-build-cloud >/dev/null;then
        echo change the hostname
        if ! cat /etc/sysconfig/network | egrep '^HOSTNAME=.*' >/dev/null ;then
            echo HOSTNAME=hz-build-cloud-ohn12 >>/etc/sysconfig/network
        fi
        if ! cat /etc/hosts | egrep 'hz-build-cloud-ohn12' >/dev/null;then
            hostIp=$(ifconfig | awk '$0~/inet / && $0~/192\.168\./ {print $2}' | head -1)
            sed -i "s/^${hostIp} .*/${hostIp} hz-build-cloud-ohn12/" /etc/hosts
        fi
        chmod +x /etc/rc.d/rc.local
        if ! cat /etc/rc.d/rc.local | grep "hz-build-cloud" >/dev/null ;then
            echo hostname hz-build-cloud-cbts >>/etc/rc.d/rc.local
        fi
        hostname hz-build-cloud-cbts
    fi
fi

if [ -h "/usr/bin/python" ];then rm -rf /usr/bin/python_bak;mv -f /usr/bin/python /usr/bin/python_bak;fi
ln -s /usr/bin/python3 /usr/bin/python || echo link /usr/bin/python failed >error.log

mkdir -p /root/FDT/
cd /root/FDT/
wget https://github.com/fast-data-transfer/fdt/releases/download/0.25.1/fdt.jar
