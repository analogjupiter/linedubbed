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

# Handle args.
while getopts ":y" opt; do
    case "${opt}" in
        y)
            confirmInstallation='y'
            ;;
		\?)
			errorln "Unknown argument."
			exit 1
			;;
		*)
			errorln "An unhandled getopts error occurred."
			exit 1
    esac
done

if [ "$confirmInstallation" != 'y' ]; then
	# Prompt user confirmation.
	read -p 'Update lineDUBbed runner? [Yn]' -r confirmInstallation
	if [ "$confirmInstallation" != 'y' ] && [ "$confirmInstallation" != 'Y' ] && [ "$confirmInstallation" != '' ]; then
		writeln Installation canceled.
		exit 1
	fi
fi

# Install dependencies.
writeln '= Installing dependencies.'
composer install --no-dev --optimize-autoloader -n

# Goodbye.
writeln '= Update completed.'
exit 0