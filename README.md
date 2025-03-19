# Install

1. Install Docker on you Apple Silicon machine (Apple Chip, not Intel Chip)
2. Clone this repo
3. `zsh ./scripts/setup.sh`
4. Follow the instructions... it will install rosetta if not already installed, then it will try automatically to configure docker with 2G of Swap and Rosetta support. If it's not able you gotta do it manually.

# Start

To start the container just execute `./scripts/start_container.sh` and it will also start the VNC server automatically and open the Screen Sharing APP of the Mac.

# Notes

1. If you need to install other utilities, change the DockerFile then execute `./scripts/gen_image.sh` to rebuild and then launch normally
2. Everything that you need persistent, you MUST keep in the home folder /home/user and is bind mounted to ./
    1. Everything that is outside /home/user will be lost upon stopping the container
