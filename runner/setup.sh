#!/usr/bin/env bash
set -e

writeln() {
	echo "$@" >&2
}

errorln() {
	writeln "Error: $@"
}

installPath='/opt/linedubbed'
repoURL='https://github.com/analogjupiter/linedubbed.git'
repoBranch='stable'

# Not running as root?
eUid="$(id -u)"
if [ "$eUid" != '0' ]; then
	errorln 'This script must be run as `root`. You might want to try `sudo` or `doas`.'
	exit 1
fi

# Missing os-release file?
if [ ! -f '/etc/os-release' ]; then
	errorln 'Cannot find `/etc/os-release`.'
	exit 1
fi

# Unsupported OS?
source /etc/os-release
if [ "$ID" != 'linuxmint' ]; then
	errorln "Unsupported OS \`${ID}\` - aka \`${PRETTY_NAME}\`."
	exit 1
fi

# Is lineDUBbed already installed?
if [ -d "$installPath" ]; then
	errorln "Path \`${installPath}\` exists. Looks like lineDUBbed has already been installed."
	exit 1
fi

# Prompt user confirmation.
read -p 'Install lineDUBbed runner? [yN]' -r confirmInstallation
if [ "$confirmInstallation" != 'y' ] && [ "$confirmInstallation" != 'Y' ]; then
	writeln Installation canceled.
	exit 1
fi

# Install dependencies.
apt-get update
apt-get -y install \
	composer \
	git \
	php-cli \
	php-curl

# Download application.
git clone -b "$repoBranch" --single-branch --depth=1 "$repoURL" "$installPath"

# Run updater.
pushd "${installPath}/runner"
./updater.sh
popd

# Goodbye.
writeln 'Installation completed.'
exit 0