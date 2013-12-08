#!/bin/bash
# Manage: Host Remove

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

	# Remove User
	manage-host-manage-remove $USER $HOST
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

	# Loop Through Users
	while echo $USERLIST | grep -q \,; do
		# Define Variables
		USER=${USERLIST%%\,*}
		HOST=${HOSTLIST%%\,*}
		# Remove Current From List
		USERLIST=${USERLIST#*\,}
		PASSLIST=${PASSLIST#*\,}

		# Check User Array State
		manage-host-check-array $HOSTLIST

		# Module Function
		module
	done

	# Unset Arrays
	unset USERLIST
	unset HOSTLIST

	# Unset Variables
	unset USER
	unset HOST
fi

# Unset Init
unset -f init