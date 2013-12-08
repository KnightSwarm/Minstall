#!/bin/bash
# Manage: Host Manage

# Check Package
check_package_message "" "nginx" "install-http-nginx"

# Manage User
manage-user

# Manage Host
manage-host

# Module Function
module() {
	# Check User
	manage-user-check-user $USER

	# Check Host
	manage-host-check-host $USER $HOST

	# Enable Host Question
	if question --default yes "Do you want to enable this host? (Y/n)" || [ $ENABLE = 1 ]; then
		manage-host-enable-host $USER $HOST
	else
		manage-host-disable-host $USER $HOST
	fi

	# Host Cache Question
	if question --default yes "Do you want to enable caching for static resources? (Y/n)" || [ $CACHE = 1 ]; then
		manage-host-enable-cache $USER $HOST
	else
		manage-host-disable-cache $USER $HOST
	fi

	# Host Hidden File Deny Question
	if question --default yes "Do you want to deny all access to hidden files? (Y/n)" || [ $DENY = 1 ]; then
		manage-host-enable-deny $USER $HOST
	else
		manage-host-disable-deny $USER $HOST
	fi

	# Host PHP Question
	if question --default yes "Do you want to enable PHP for this host? (Y/n)" || [ $PHP = 1 ]; then
		manage-host-enable-php $USER $HOST
	else
		manage-host-disable-php $USER $HOST
	fi

	# Host SSL Question
	if question --default yes "Do you want to enable SSL for this host? (Y/n)" || [ $SSL = 1 ]; then
		manage-host-enable-ssl $USER $HOST
	else
		manage-host-disable-ssl $USER $HOST
	fi
	
	# Restart Daemon
	subheader "Restarting Daemon..."
	daemon_manage nginx restart
}

# Attended Mode
if [ $UNATTENDED = 0 ]; then
	# User Check
	manage-user-input-check
	
	# Host Input
	manage-host-input-check $USER

	# Module Function
	module
# Unattended Mode
else
	# Define Arrays
	USERLIST=$(read_variable_module user),
	HOSTLIST=$(read_variable_module host),
	ENABLELIST=$(read_variable_module enable),
	CACHELIST=$(read_variable_module cache),
	DENYLIST=$(read_variable_module deny),
	PHPLIST=$(read_variable_module php),
	SSLLIST=$(read_variable_module ssl),

	# Loop Through Users
	while echo $USERLIST | grep -q \,; do
		# Define Variables
		USER=${USERLIST%%\,*}
		HOST=${HOSTLIST%%\,*}
		ENABLE=${ENABLELIST%%\,*}
		CACHE=${CACHELIST%%\,*}
		DENY=${DENYLIST%%\,*}
		PHP=${PHPLIST%%\,*}
		SSL=${SSLLIST%%\,*}

		# Remove Current From List
		USERLIST=${USERLIST#*\,}
		PASSLIST=${PASSLIST#*\,}
		ENABLELIST=${ENABLELIST#*\,}
		CACHELIST=${CACHELIST#*\,}
		DENYLIST=${DENYLIST#*\,}
		PHPLIST=${PHPLIST#*\,}
		SSLLIST=${SSLLIST#*\,}

		# Check User Array State
		manage-host-check-array $HOSTLIST

		# Module Function
		module
	done

	# Unset Arrays
	unset USERLIST
	unset HOSTLIST
	unset ENABLELIST
	unset CACHELIST
	unset DENYLIST
	unset PHPLIST
	unset SSLLIST

	# Unset Variables
	unset USER
	unset HOST
	unset ENABLE
	unset CACHE
	unset DENY
	unset PHP
	unset SSL
fi

# Unset Init
unset -f init