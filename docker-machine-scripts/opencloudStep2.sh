serverName=$1

# To create a new user in Ubuntu. Call it whatever you want.
docker-machine ssh $serverName 'adduser --disabled-password --gecos "" acuity'
# Add the user to sudoers in case it needs it.
docker-machine ssh $serverName 'usermod -aG docker acuity'
docker-machine ssh $serverName 'chmod 640 /etc/sudoers'
docker-machine ssh $serverName 'echo "acuity ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

docker-machine ssh $serverName "mkdir /home/acuity/.ssh"
cat ~/.ssh/id_rsa.pub | docker-machine ssh $serverName 'cat - >> /home/acuity/.ssh/authorized_keys'
docker-machine ssh $serverName "chown -R acuity:acuity /home/acuity/.ssh"
