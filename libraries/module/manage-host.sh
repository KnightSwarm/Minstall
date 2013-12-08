#!/bin/bash
# Common Functions For Module: Manage Host

# Manage User
manage-user

# Module Functions
manage-host() {
	#####################
	## Check Functions ##
	#####################

	# Check If Array Empty
	manage-host-check-array() {
		if [ $1 = 0 ]; then
			# Print Message
			error "No hosts in host array. Aborting."

			# Exit Loop
			break
		fi
	}

	# Check If User HTTP Directory Exists
	manage-host-check-http() {
		if [ ! -d /home/$1/http ]; then
			# Print Message
			echo "User does not have HTTP directory ($1)."

			# Continue Loop
			continue
		fi
	}

	# Check If User Exists
	manage-host-check-host() {
		if [ ! -f /etc/nginx/sites-available/$1-$2.conf ]; then
			# Print Message
			echo "Invalid host ($2)."

			# Continue Loop
			continue
		fi
	}

	###########################
	## Interactive Functions ##
	###########################

	# Input Check
	manage-host-input-check() {
		# Check Loop
		while true; do
			# Take Input
			read -p "Please enter a host: " HOST

			# Check Input
			if [ -f /etc/nginx/sites-available/$1-$HOST.conf ]; then
				# Exit Loop
				break
			else
				# Print Error
				echo "Invalid host. Ensure the host exists on the system."
			fi
		done
	}

	# Input Host
	manage-host-input-host() {
		# Check Loop
		while true; do
			# Take Input
			read -p "Please enter a host: " HOST

			if grep -q '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$' <<< $HOST; then
			# Check Input
				# Exit Loop
				break
			else
				# Print Error
				echo "Invalid host. Ensure the hostname is of valid format."
			fi
		done
	}

	##########################
	## Management Functions ##
	##########################

	# Add Host
	manage-host-manage-add() {
		subheader "Creating Host Directory..."
		mkdir /home/$1/http/hosts/$2

		subheader "Changing Host Directory Permissions..."
		chown -R $1:$1 /home/$USER/http/hosts/$2
		chmod 770 /home/$USER/http/hosts/$2
		
		subheader "Adding Configuration..."
		cp $MODULEPATH/$MODULE/etc/nginx/sites-available/template.conf /etc/nginx/sites-available/$1-$2.conf
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "\$USER" "$1"
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "\$HOST" "$2"
		touch /etc/nginx/custom.d/$1-$2.conf
	}

	# Remove User
	manage-host-manage-remove() {
		subheader "Removing Host Configuration..."
		rm -rf /etc/nginx/custom.d/$1-$2.conf
		rm -rf /etc/nginx/sites-*/$1-$2.conf

		subheader "Removing Host Directory..."
		rm -rf /home/$1/http/hosts/$2
	}

	# Enable Host
	manage-host-enable-host() {
		subheader "Enabling Host..."
		ln -s /etc/nginx/sites-available/$1-$2.conf /etc/nginx/sites-enabled/$1-$2.conf
	}

	# Disable Host
	manage-host-disable-host() {
		subheader "Disabling Host..."
		rm /etc/nginx/sites-enabled/$1-$2.conf
	}

	# Enable Caching
	manage-host-enable-cache() {
		subheader "Enabling Caching..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "#include /etc/nginx/conf.d/cache.conf" "include /etc/nginx/conf.d/cache.conf"
	}

	# Disable Caching
	manage-host-disable-cache() {
		subheader "Disabling Caching..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "include /etc/nginx/conf.d/cache.conf" "#include /etc/nginx/conf.d/cache.conf"
	}

	# Enable Hidden File Access Denial
	manage-host-enable-deny() {
		subheader "Enabling Hidden File Block..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "#include /etc/nginx/conf.d/deny.conf" "include /etc/nginx/conf.d/deny.conf"
	}

	# Disable Hidden File Access Denial
	manage-host-disable-deny() {
		subheader "Disabling Hidden File Block..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "include /etc/nginx/conf.d/deny.conf" "#include /etc/nginx/conf.d/deny.conf"
	}

	# Enable PHP
	manage-host-enable-php() {
		subheader "Enabling PHP..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "#include /etc/nginx/php.d/" "include /etc/nginx/php.d/"
	}

	# Disable PHP
	manage-host-disable-php() {
		subheader "Disabling PHP..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "include /etc/nginx/php.d/" "#include /etc/nginx/php.d/"
	}

	# Enable SSL
	manage-host-enable-ssl() {
		subheader "Enabling SSL..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "#listen 443 ssl" "listen 443 ssl"
	}

	# Disable SSL
	manage-host-disable-ssl() {
		subheader "Disabling SSL..."
		string_replace_file /etc/nginx/sites-available/$1-$2.conf "listen 443 ssl" "#listen 443 ssl"
	}
}