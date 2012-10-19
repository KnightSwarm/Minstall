#!/bin/bash
# Clean: Packages

# Module Warning
warning "This module will remove all non-essential packages on this system, you have been warned!"
if ! (question --default yes "Do you still want to run this module and purge all non-essential packages? (Y/n)" || [ $UNATTENDED = 1 ]); then
	# Skipped Message
	subheader "Skipping Module..."
	# Skip Module
	continue
fi

# Stopping Sendmail daemon
if check_package "sendmail"; then
	subheader "Stopping Sendmail daemon..."
	daemon_manage sendmail stop
fi

# Update Package Lists
subheader "Updating Package Lists..."
package_update

# Create Package List
subheader "Creating Package List..."
cp $MODULEPATH/$MODULE/$DISTRIBUTION/base temp.packages.list

# Check Platform
if ! ([ $PLATFORM = "openvz" ] || [ $PLATFORM = "vserver" ]); then
	# Append Hardware Package List
	cat $MODULEPATH/$MODULE/$DISTRIBUTION/base-hardware >> temp.packages.list
fi

# Check Platform Package List
if [ -f $MODULEPATH/$MODULE/$DISTRIBUTION/specific-$PLATFORM-$ARCHITECTURE ]; then
	# Append Platform Package List
	cat $MODULEPATH/$MODULE/$DISTRIBUTION/specific-$PLATFORM-$ARCHITECTURE >> temp.packages.list
fi

# Append Custom Package List
cat $MODULEPATH/$MODULE/$DISTRIBUTION/custom >> temp.packages.list

# Sort Package List
sort -o temp.packages.list temp.packages.list

# Run Pre Install Commands
source $MODULEPATH/$MODULE/$DISTRIBUTION/script-install.sh

# Clean Packages
subheader "Cleaning Packages..."
clean_packages

# Clean Files
subheader "Cleaning Files..."
clean_files

# Run Post Install Commands
source $MODULEPATH/$MODULE/$DISTRIBUTION/script-post.sh

# Remove Temporary Files
rm temp.*

# Clean Packages
package_clean

# Clean Package List
package_clean_list

# Show Warnings
warning "All SSH Servers have been uninstalled! Be sure to install an SSH server again using the modules provided (install-dropbear or install-ssh)!"
warning "Also, it is recommend that you restart your server after installing an SSH server to ensure everything is functional (due to kernel updates and such) and to ensure that all changes are loaded."
