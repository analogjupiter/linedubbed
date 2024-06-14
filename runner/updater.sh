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
            confirmUpdate='y'
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

if [ "$confirmUpdate" != 'y' ]; then
	# Prompt user confirmation.
	read -p 'Update lineDUBbed runner? [Yn]' -r confirmUpdate
	if [ "$confirmUpdate" != 'y' ] && [ "$confirmUpdate" != 'Y' ] && [ "$confirmUpdate" != '' ]; then
		writeln Update canceled.
		exit 1
	fi
fi

# Update repo.
writeln '= Pulling latest version.'
doas -u ldub \
	git pull --ff-only

# Install dependencies.
writeln '= Installing dependencies.'
doas -u ldub \
	composer install --no-dev --optimize-autoloader -n

writeln '= Migrating installation.'
./ldr ldr:upgrade

# Goodbye.
writeln '= Update completed.'
exit 0
