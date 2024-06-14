#!/usr/bin/env bash
set -e

writeln() {
	echo "$@" >&2
}

errorln() {
	writeln "Error: $@"
}

doasConf='/etc/doas.conf'
userName='ldub'
homePath="/opt/${userName}"
installPath="${homePath}/install"
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
if [ "$ID" != 'debian' ]; then
	errorln "Unsupported OS \`${ID}\` - aka \`${PRETTY_NAME}\`."
	exit 1
fi

# Is lineDUBbed already installed?
if [ -d "$installPath" ]; then
	errorln "Path \`${installPath}\` already exists. Looks like lineDUBbed/runner has already been installed."
	exit 1
fi

# Left-overs?
if id -u "$userName" >/dev/null 2>&1; then
	errorln "User \`${userName}\` already exists. Please install lineDUBbed on a clean system."
	exit 1
fi

# Left-overs? (2)
if [ -d "$homePath" ]; then
	errorln "Path \`${homePath}\` already exists. Looks like lineDUBbed/runner has already been installed."
	exit 1
fi

# Prompt user confirmation.
read -p 'Install lineDUBbed/runner? [yN]' -r confirmInstallation
if [ "$confirmInstallation" != 'y' ] && [ "$confirmInstallation" != 'Y' ]; then
	writeln Installation canceled.
	exit 1
fi

# Install dependencies.
writeln '= Installing dependencies.'
apt-get update
apt-get -y install \
	composer \
	doas \
	git \
	php-cli \
	php-curl

# Create user.
writeln '= Creating user.'
useradd \
	--system \
	--create-home \
	--home-dir /opt/ldub \
	--shell /usr/sbin/nologin \
	"$userName"

# Configure doas.
writeln '= Configuring `doas`.'
echo "permit nopass root as ${userName}" >>"$doasConf"

# Download application.
writeln '= Downloading repository.'
doas -u "$userName" \
	git clone -b "$repoBranch" --single-branch --depth=1 "$repoURL" "$installPath"

# Run updater.
writeln '= Launching updater to finalize the installation process.'
pushd "${installPath}/runner"
./updater.sh -y
popd

# Goodbye.
writeln '= Installation completed.'
exit 0
