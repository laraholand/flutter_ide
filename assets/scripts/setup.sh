#!/bin/bash
#install curl
echo 'Need more space'
pkg update && pkg upgrade -y
pkg install curl -y
curl -sL https://termuxvoid.github.io/repo/install.sh | bash
pkg update && pkg upgrade-y
pkg install android-sdk -y
pkg install flutter -y