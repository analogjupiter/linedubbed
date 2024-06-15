#!/usr/bin/env bash
set -e

#================================#
# lineDUBbed/runner setup script #
#================================#

writeln() {
	echo "$@" >&2
}

errorln() {
	writeln "Error: $@"
}

userInstaller='ldri'
userInstallerHome="/opt/ldr"
userDaemon='ldrd'
userDaemonHome="/var/lib/ldr"

doasConf='/etc/doas.conf'
installPath="${userInstallerHome}/app"
updateHelperPath="${userInstallerHome}/update.sh"
serviceUnitPath='/etc/systemd/system/ldrd.service'

repoURL='https://github.com/analogjupiter/linedubbed.git'
branch='main'

# Script

if [ -n "${LDR_BRANCH}" ]; then
	branch=${LDR_BRANCH}
fi

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
if [ "${ID}" != 'debian' ]; then
	errorln "Unsupported OS \`${ID}\` - aka \`${PRETTY_NAME}\`."
	exit 1
fi

# Is lineDUBbed already installed?
if [ -d "${installPath}" ]; then
	errorln "Path \`${installPath}\` already exists. Looks like lineDUBbed/runner has already been installed."
	exit 1
fi

# Left-overs?
if id -u "${userInstaller}" >/dev/null 2>&1; then
	errorln "User \`${userInstaller}\` already exists. Please install lineDUBbed on a clean system."
	exit 1
fi

# Left-overs? (2)
if id -u "${userDaemon}" >/dev/null 2>&1; then
	errorln "User \`${userDaemon}\` already exists. Please install lineDUBbed on a clean system."
	exit 1
fi

# Left-overs? (3)
if [ -d "${userInstallerHome}" ]; then
	errorln "Path \`${userInstallerHome}\` already exists. Looks like lineDUBbed/runner has already been installed."
	exit 1
fi

# Left-overs? (4)
if [ -d "${userDaemonHome}" ]; then
	errorln "Path \`${userDaemonHome}\` already exists. Looks like lineDUBbed/runner has already been installed."
	exit 1
fi

# Left-overs? (5)
if [ -d "${serviceUnitPath}" ]; then
	errorln "Path \`${serviceUnitPath}\` already exists. Looks like lineDUBbed/runner has already been installed."
	exit 1
fi

# Prompt user confirmation.
read -p 'Install lineDUBbed/runner on this system? [yN] ' -r confirmInstallation
if [ "${confirmInstallation}" != 'y' ] && [ "${confirmInstallation}" != 'Y' ]; then
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

# Create users.
writeln '= Creating users.'
# Create "installer" user.
useradd \
	--system \
	--create-home \
	--home-dir "${userInstallerHome}" \
	--shell /usr/sbin/nologin \
	"${userInstaller}"
# Create "daemon" user.
useradd \
	--system \
	--create-home \
	--home-dir "${userDaemonHome}" \
	--shell /usr/sbin/nologin \
	"${userDaemon}"

# Configure doas.
writeln '= Configuring `doas`.'
echo "# == lineDUBbed/runner ==
permit nopass root as ${userInstaller}
permit nopass ${userInstaller} as ${userInstaller}
permit nopass ${userInstaller} as root cmd /bin/systemctl args start   ldrd.service
permit nopass ${userInstaller} as root cmd /bin/systemctl args stop    ldrd.service
permit nopass ${userInstaller} as root cmd /bin/systemctl args restart ldrd.service
permit nopass ${userInstaller} as ${userDaemon}
# == lineDUBbed/runner end ==" \
	>> "${doasConf}"

# Download application.
writeln '= Downloading repository.'
doas -u "${userInstaller}" \
	git clone -b "${branch}" --single-branch --depth=1 "${repoURL}" "${installPath}"

# Install service.
writeln '= Installing daemon as service-unit.'
echo "[Unit]
Description=lineDUBbed/runner daemon
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${userDaemonHome}
ExecStart=${installPath}/runner/ldr ldr:daemon
TimeoutStartSec=0
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target" \
	> "${serviceUnitPath}"
systemctl daemon-reload

# Create update-helper.
writeln '= Installing update-helper script.'
echo "#!/bin/sh
args=\"\$@\"
doas -u ${userInstaller} sh -c \"cd '${installPath}/runner' && ./update.sh \${args}\"" \
	> "${updateHelperPath}"
chmod +x "${updateHelperPath}"

# Run updater.
writeln '= Launching updater to finalize the installation process.'
"${updateHelperPath}" -y
writeln '= Finalization successful.'

# Goodbye.
writeln '= Installation completed.'

# Enable/start LDR?
writeln ''
read -p 'Do you want to enable the lineDUBbed/runner daemon now? [Yn] ' -r confirmDaemon
if [ "${confirmDaemon}" != 'y' ] && [ "${confirmDaemon}" != 'Y' ] && [ "${confirmDaemon}" != '' ]; then
	writeln '= Won''t enable daemon (for now).'
	exit 0
fi

# Enable + start service.
systemctl enable --now ldrd.service
writeln '= Daemon has been enabled.'
exit 0
