## change root password
passwd

## add user
useradd -d /home/kerthcet -m kerthcet
passwd kerthcet

## Manage Docker as a non-root user(https://docs.docker.com/engine/install/linux-postinstall/)
#### root privilege
groupadd docker
usermod -aG docker kerthcet

# ## set sshd_config
# vi /etc/ssh/sshd_config
# PasswordAuthentication yes
# AllowUsers kerthcet

# ## restart sshd
# systemctl restart sshd

# # su root
# su kerthcet
# cd /home/kerthcet
# mkdir .ssh
# vi .ssh/authorized_keys # 输入public key
# chmod 600 .ssh/authorized_keys

