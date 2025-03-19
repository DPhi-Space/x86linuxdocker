#!/bin/zsh

# starts the Docker container and xvcd for USB forwarding

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/header.sh"
validate_macos

# this is called when the container stops or ctrl+c is hit
function stop_container {
    docker kill vivado_container > /dev/null 2>&1
    f_echo "Stopped Docker container"
    exit 0
}
trap 'stop_container' INT

# Make sure everything is setup to run the container
start_docker
if [[ $(docker ps) == *vivado_container* ]]
then
    f_echo "There is already an instance of the container running."
    exit 1
fi

# run container
docker run --init --rm --name vivado_container --mount type=bind,source="$script_dir/..",target="/home/user/" -p 127.0.0.1:5901:5901 --platform linux/amd64 x64-linux-generic sudo -H -u user bash /home/user/scripts/linux_start.sh &
f_echo "Started container"
sleep 10
f_echo "Starting VNC viewer"
vncpass=$( tr -d "\n\r\t " < "$script_dir/vncpasswd" )
osascript -e "tell application \"Screen Sharing\" to GetURL \"vnc://user:$vncpass@localhost:5901\""
# while vivado_container is running
while [[ $(docker ps) == *vivado_container* ]]
do
  sleep 1
done
stop_container
