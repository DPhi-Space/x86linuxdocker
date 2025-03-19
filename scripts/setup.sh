#!/bin/zsh

# Initial setup on host (macOS) side

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/header.sh"
# Make sure that the script is run in macOS and not the Docker container
validate_macos

# Make sure permissions are right
if [[ "$current_user" == "root" ]]
then
	f_echo "Do not execute this script as root."
	exit 1
fi

validate_internet

# Check if the Mac is Intel or Apple Silicon
if [[ "$(uname -m)" == "x86_64" ]]; then
	f_echo "Mac is Intel-based. Rosetta installation is not required."
else
	if arch -arch x86_64 uname -m > /dev/null 2>&1; then
		f_echo "Rosetta is already installed."
	else
		f_echo "Rosetta is not installed."
		f_echo "Proceeding with Rosetta installation..."
		if ! softwareupdate --install-rosetta --agree-to-license; then
			f_echo "Error installing Rosetta."
			exit 1
		fi
	fi
fi

# Make the user own the whole folder
if ! chown -R $current_user "$script_dir/.."
then
	f_echo "Higher privileges are required to make the folder owned by the user."
	if ! sudo chown -R $current_user "$script_dir/.."
	then
		f_echo "Error setting $current_user as owner of this folder."
		exit 1
	fi
fi
if ! chmod +x "$script_dir"/*.sh 
then
	f_echo "Error making the scripts executable."
	exit 1
fi

# make sure that Docker is installed
start_docker

# Attempt to enable Rosetta and set swap to at least 2GiB in Docker
eval "$script_dir/configure_docker.sh"

# Generate the Docker image
if ! eval "$script_dir/gen_image.sh"
then
	exit 1
fi

# Set VNC resolution
f_echo "Set the resolution of the container. Keep in mind that high resolutions might make text and images appear small."
f_echo "You can change the resolution manually in the vnc_resolution file later."
f_echo "Press enter to leave the default (1920x1080) or type in your preference:"
read resolution
# if resolution has the right format
if [[ $resolution =~ "^[0-9]+x[0-9]+$" ]]
then
	f_echo "Setting $resolution as resolution"
	echo "$resolution" > "$script_dir/vnc_resolution"
else
	f_echo "Setting the default of $vnc_default_resolution"
	echo "$vnc_default_resolution" > "$script_dir/vnc_resolution"
fi
echo ""
