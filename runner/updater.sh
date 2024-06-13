#!/usr/bin/env bash
set -e

writeln() {
	echo "$@" >&2
}

errorln() {
	writeln "Error: $@"
}

sentinelFile='.linedubbed-runner-repo'

# Wrong working-directory?
if [ ! -f "$sentinelFile" ]; then
	errorln 'This script must be run from the `linedubbed/runner` installation directory.'
	writeln "Current working-directory: \`$(pwd)\`"
	exit 1
fi

# Not running as root?
eUid="$(id -u)"
if [ "$eUid" != '0' ]; then
	errorln 'This script must be run as `root`. You might want to try `sudo` or `doas`.'
	exit 1
fi

# Prompt user confirmation.
read -p 'Install lineDUBbed runner? [yN]' -r confirmInstallation
if [ "$confirmInstallation" != 'y' ] && [ "$confirmInstallation" != 'Y' ]; then
	writeln Installation canceled.
	exit 1
fi

# Install dependencies.
writeln '= Installing dependencies.'
composer install --no-dev --optimize-autoloader -n

# Goodbye.
writeln 'Installation completed.'
exit 0