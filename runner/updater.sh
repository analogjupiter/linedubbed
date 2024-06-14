#!/usr/bin/env bash
set -e

#==================================#
# lineDUBbed/runner updater script #
#==================================#

writeln() {
	echo "$@" >&2
}

errorln() {
	writeln "Error: $@"
}

userInstaller='ldri'
sentinelFile='.linedubbed-runner-repo'

# Wrong working-directory?
if [ ! -f "${sentinelFile}" ]; then
	errorln 'This script must be run from the `linedubbed/runner` installation directory.'
	writeln "Current working-directory: \`$(pwd)\`"
	exit 1
fi

# Not running as "installer"?
if [ "$(whoami)" != "${userInstaller}" ]; then
	errorln "This script must be run as user \`${userInstaller}\`."
	writeln "You might want to try \`doas -u ${userInstaller} ./updater.sh\`."
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

if [ "${confirmUpdate}" != 'y' ]; then
	# Prompt user confirmation.
	read -p 'Update lineDUBbed runner? [Yn]' -r confirmUpdate
	if [ "${confirmUpdate}" != 'y' ] && [ "${confirmUpdate}" != 'Y' ] && [ "${confirmUpdate}" != '' ]; then
		writeln 'Update canceled.'
		exit 1
	fi
fi

# Check whether service is running.
set +e
systemctl is-active --quiet ldrd.service
[ $? -eq 0 ] && daemonWasRunning=true || daemonWasRunning=false
set -e

# Stop service.
if [ $daemonWasRunning == true ]; then
	writeln '= Stopping the LDR daemon.'
	doas -u root /bin/systemctl stop ldrd.service
fi

# Update repo.
writeln '= Pulling latest version.'
git pull --ff-only

# Install dependencies.
writeln '= Installing dependencies.'
composer install --no-dev --optimize-autoloader -n

writeln '= Migrating installation.'
./ldr ldr:upgrade

# Restart service.
if [ $daemonWasRunning == true ]; then
	writeln '= Restarting the LDR daemon.'
	doas -u root /bin/systemctl start ldrd.service
fi

# Goodbye.
writeln '= Update completed.'
exit 0
