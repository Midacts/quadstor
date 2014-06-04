#!/bin/bash
# QUADStor Installation Script
# Date: 2nd of June, 2014
# Version 1.0
#
# Author: John McCarthy
# Email: midactsmystery@gmail.com
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#---------------------------------------------------------------
function install_quadstor(){
	# Install prerequisite packages
		echo
		echo -e '\e[01;34m+++ Installing the prerequisite software...\e[0m'
		apt-get update
		apt-get -y install apache2 build-essential git linux-headers-`uname -r` psmisc sg3-utils sudo uuid-runtime
		echo -e '\e[01;37;42mThe prerequisite software has been successfully installed!\e[0m'

	# Install Quadstor
		echo
		echo -e '\e[01;34m+++ Installing QUADStor...\e[0m'
		git clone --branch opensource https://github.com/quadstor/quadstorvirt.git quadstor
		cd quadstor
		./installworld debian7
		echo -e '\e[01;37;42mQUADStor has been successfully installed!\e[0m'

	#Start the quadstor service
		echo
		echo -e '\e[01;34m+++ Starting the Quadstor service...\e[0m'
		echo
		service quadstor start
		echo
		echo -e '\e[01;37;42mThe Quadstor service has been successfully started!\e[0m'
}
function secure_webui(){
	# Creates the .htaccess file
		echo
		echo -e '\e[01;34m+++ Creating the .htaccess file...\e[0m'
		cat << 'EOA' > /usr/lib/cgi-bin/.htaccess
AuthName "QUADStor VTL Authentication"
AuthType Basic
AuthUserFile /usr/lib/cgi-bin/.htpasswd
Require valid-user

EOA

		echo -e '\e[01;37;42mThe .htaccess file has been successfully created!\e[0m'

	# Creates the htpasswd with the your username and password
		echo
		echo -e '\e[01;34m+++ Creating the .htpasswd file...\e[0m'
		echo
		echo -e '\e[33mWhat \e[33;01musername\e[0m \e[33mwould you like to use for logging into the Quadstor web UI ?\e[0m'
		read user

		echo
		echo -e '\e[33mWhat \e[33;01mpassword\e[0m \e[33mwould you like to use for this user ?\e[0m'
		read pass
		htpasswd -bcs /usr/lib/cgi-bin/.htpasswd $user $pass
		echo -e '\e[01;37;42mThe .htpasswd file has been successfully created!\e[0m'

	# Edits your apache2 site to use the .htaccess file and SSL
		echo
		echo -e '\e[01;34m+++ Editing the /etc/apache2/sites-available/default file...\e[0m'
		cp /etc/apache2/sites-available/default /etc/apache2/sites-available/default.BAK
		sed -i 's/Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch/Options None/g' /etc/apache2/sites-available/default
		sed -i 's/AllowOverride None/AllowOverride AuthConfig Limit/g' /etc/apache2/sites-available/default
		sed -i '22i\                SSLRequireSSL' /etc/apache2/sites-available/default

		echo
		echo -e '\e[33mChoose your Certificates Name\e[0m'
		read cert
		mkdir /etc/apache2/ssl
		cd /etc/apache2/ssl
		openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout $cert.key -out $cert.crt

		sed -i "27i\                SSLEngine On" /etc/apache2/sites-available/default
		sed -i "27i\                SSLCertificateFile /etc/apache2/ssl/$cert.crt" /etc/apache2/sites-available/default
		sed -i "27i\                SSLCertificateKeyFile /etc/apache2/ssl/$cert.key" /etc/apache2/sites-available/default

		sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:443>/g' /etc/apache2/sites-available/default
		sed -i '1i<VirtualHost \*:80>' /etc/apache2/sites-available/default
		sed -i '2i</VirtualHost>' /etc/apache2/sites-available/default
		echo -e '\e[01;37;42mThe /etc/apache2/sites-available/default site has been successfully edited!\e[0m'

	# Enables the required apache2 mods and restarts the apache2 service
		echo
		echo -e '\e[01;34m+++ Enabling modules and restarting apache2...\e[0m'
		a2enmod ssl
		service apache2 restart
		echo -e '\e[01;37;42mThe apache2 service has been successfully restarted!\e[0m'
}
function doAll(){
	# Calls Function 'install-quadstor'
		echo
		echo
		echo -e "\e[33m=== Install QUADStor ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			install_quadstor
		fi

	# Calls Function 'secure_webui'
		echo
		echo -e "\e[33m=== Secure access to your QUADStor Web UI  ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			secure_webui
		fi

	# Gets the IP of the Ubiquiti unifi controller
		ipaddr=`hostname -I`
		ipaddr=$(echo "$ipaddr" | tr -d ' ')

	# End of Script Congratulations, Farewell and Additional Information
		clear
		farewell=$(cat << EOZ


           \e[01;37;42mWell done! You have successfully setup your MHVTL server! \e[0m

                               \e[01;37mhttps://$ipaddr\e[0m


  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m

                            \e[01;37m########################\e[0m
                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
                            \e[01;37m########################\e[0m
EOZ
)

		#Calls the End of Script variable
		echo -e "$farewell"
		echo
		echo
		exit 0
}

# Check privileges
	[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
	clear
	welcome=$(cat << EOA


           \e[01;37;42mWelcome to Midacts Mystery's QUADStor Installation Script!\e[0m


EOA
)

# Calls the welcome variable
	echo -e "$welcome"

# Calls the doAll function
	case "$go" in
		* )
			doAll ;;
	esac
