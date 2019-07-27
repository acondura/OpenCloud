serverName=$1
echo ""
echo " 1. Create the server with Docker"
docker-machine rm -y $serverName
docker-machine create --driver=digitalocean --digitalocean-access-token=6ad0031012fb9e8e76ffb21d7679d76c1374a658abec6b45450eab603ac5a845 --digitalocean-image=debian-9-x64 --digitalocean-size 1gb --digitalocean-monitoring=true --digitalocean-region=tor1 $serverName

echo ""
echo " 2. Set it as the active server to send commands to"
eval $(docker-machine env $serverName)

echo ""
echo " 3. Update Debian OS to the latest updates"
docker-machine ssh $serverName "apt-get update"

echo ""
echo " 4. Install Git and other useful tools"
docker-machine ssh $serverName "apt-get -y install git wget unzip composer; apt -y remove unscd;"

# To create a new user in Ubuntu. Call it whatever you want.
docker-machine ssh $serverName 'adduser --disabled-password --gecos "" docksal'
# Add the user to sudoers in case it needs it.
docker-machine ssh $serverName 'usermod -aG docker docksal'
docker-machine ssh $serverName 'chmod 640 /etc/sudoers'
docker-machine ssh $serverName 'echo "docksal ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

docker-machine ssh $serverName "mkdir /home/docksal/.ssh"
cat ~/.ssh/id_rsa.pub | docker-machine ssh $serverName 'cat - >> /home/docksal/.ssh/authorized_keys'
docker-machine ssh $serverName "chown -R docksal:docksal /home/docksal/.ssh"

# echo ""
# echo " 5. Install Docksal"
# docker-machine ssh $serverName "curl -fsSL get.docksal.io | sh"
