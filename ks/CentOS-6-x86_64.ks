# Kickstart file to build base CentOS 6 image
install
cdrom

# CentOS-6-x86_64
lang en_US.UTF-8
keyboard us
timezone --utc America/New_York
authconfig --enableshadow --passalgo=sha512
auth  --useshadow  --enablemd5
selinux --disabled
firewall --enabled --service=ssh
firstboot --disable
text
skipx
reboot

# openssl passwd -1 -salt $(date +%Y%m%d) 'frblah'
rootpw --lock --iscrypted $1$20160229$qm2af/ZzFxosV7B2ABLQw/

bootloader --location=mbr --timeout=1
network --bootproto=dhcp --device=eth0 --activate --onboot=on --noipv6

zerombr
clearpart --all
ignoredisk --only-use=sda
part / --size 1 --grow --fstype ext4 --label _/

# Repositories
# The CentOS repos below will always end up with the latest minor version.
repo --cost=1000 --name=CentOS6-Base --mirrorlist=http://mirrorlist.centos.org/?release=6.6&arch=x86_64&repo=os
repo --cost=1000 --name=CentOS6-Updates --mirrorlist=http://mirrorlist.centos.org/?release=6.6&arch=x86_64&repo=updates

repo --cost=1000 --name=EPEL --baseurl=http://dl.fedoraproject.org/pub/epel/6/x86_64/
#repo --cost=1 --name=Puppetlabs --baseurl=http://yum.puppetlabs.com/el/6/products/x86_64/
#repo --cost=1 --name=Puppet-deps --baseurl=http://yum.puppetlabs.com/el/6/dependencies/x86_64/

# Add all the packages after the base packages
%packages --ignoremissing --excludedocs --nobase
@core
wget
sudo
-*-firmware
ack
dos2unix
dstat

# pre-gaming the chef run
ca-certificates
diffutils
eject
emacs-nox
git
krb5-workstation
lynx
nagios-nsca-client
ngrep
openldap-clients
ruby
rubygems
screen
sssd
sssd-tools
subversion
subversion-devel
subversion-perl
telnet
tmux
wireshark
xinetd

# residuals from upstream suitcase setup
htop
iftop
nc
nscd
# Use sssd eventually
nss-pam-ldapd
rsync
s3cmd
yum-utils
yum-plugin-changelog
yum-plugin-downloadonly
yum-plugin-ps

redhat-lsb
ntp

# Install kernel related packages. Used for VBox Guest Additions.  Not sure
# if elsewhere.
kernel-devel
kernel-headers
gcc
make
autoconf
dkms

# cloud-init
cloud-init

# This could be removed but would need a Puppet update to get keys from the
# internet.
epel-release

#NOTE: abrt may be worthwhile for kernel panics if we invest some time into
# learning and using it.
-abrt-*
-avahi
-crda
-dmraid
-fprintd-*
-hunspell-*
-ledmon
-libertas-*-firmware
-libreport-*
-libstoragemgmt
-lvm2
-iwl*-firmware
-ntsysv
-rubygem-abrt
-setuptool
-smartmontools
-usb_modeswitch-*
-yum-langpacks

%end

# The following is used by packer for provisioner actions.
%post
mkdir /root/.ssh
chmod 700 /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRsOlZeVl+R6EqwSPKRWMWNe8nXFAJQfV9ePyxo6HqTHUrf344yoLfe/yIgpea7vvIkc/L/SZuY6N4wazqIorbVLvKY4X+MUOAg9WS/mUr4SgtasZei7zu0DDK/rU/1/VIHYvk8UXCH89qxgyqdqmAgnk+1vfIGKr36aarZ+ognnvl4JgTJlmo27+sRzhU4ukCVno0kGLssv6IOH/K5Vp9eDXYZ12g77V90bY1OBzli9Eq6+cwZypQ9zurKg1bMWq5fwwS/x8Y7sssSGFojJcrqG+8Vh9HUNvSEikSpogYbdpSKfQjpa4g4pwJCMe4WUMVRpf8kb8/PLhiBNi5td6L Vagrant insecure key" > /root/.ssh/authorized_keys
chmod 644 /root/.ssh/authorized_keys
%end

# Disable cloud init.  It'll be reenabled by a provisioner if needed.
%post
chkconfig cloud-config off
chkconfig cloud-final off
chkconfig cloud-init off
chkconfig cloud-init-local off
%end
