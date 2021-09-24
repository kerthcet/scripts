# add user
useradd -d /home/kerthcet -m kerthcet
passwd kerthcet

# su kerthcet
# cd /home/kerthcet
# mkdir .ssh
# vi .ssh/authorized_keys # 输入public key
# chmod 600 .ssh/authorized_keys

# su root

# set sshd_config
vi /etc/ssh/sshd_config
PasswordAuthentication yes
AllowUsers kerthcet

# restart sshd
systemctl restart sshd

