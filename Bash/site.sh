#!/bin/bash
# Üllar Seerme
# Script creates a new web page with an address the user inputs as an argument.
export LC_ALL=C

# Function checks if the number of arguments is correct
function count_args {
    if [ $# == 1 ]; then
        ARG=$1
    else
        echo "Enter the right number of arguments!"
        exit 1
    fi
}

# Function checks if apache2 is installed, if not then it gets installed
function check_apache {
    dpkg -s apache2 >> /dev/null

    if [ $? == 0 ]; then
        echo "Apache is already installed!"
    else
        sudo apt-get update > /dev/null
        sudo apt-get -y install apache2 > /dev/null
        echo "Installed Apache!"
    fi
}

# Function checks if there is an address with the same name in the /etc/hosts file 
# and if there isn't, then it gets added with the localhost address
function check_name {
    grep -E "^127.0.0.1 $ARG" /etc/hosts 2> /dev/null

    if [ $? == 0 ]; then
        echo "Name resolution should work. Try pinging!"
    else
        echo "127.0.0.1 $ARG" >> /etc/hosts
        echo "Added address to /etc/hosts file!"
    fi
}

# Function checks if there is a folder by the same name in the /var/www folder 
# and if there isn't, then it gets created
function check_dir {
    ls /var/www/"$ARG" 2> /dev/null

    if [ $? == 0 ]; then
        echo "Website's home folder exists!"
    else
        mkdir /var/www/"$ARG"
        echo "Created folder $ARG inside folder /var/www!"
    fi
}

# Functions copies the default index.html folder and changes its header. 
# Changes are made in the configuration files where ServerAdmin, ServerName, 
# DocumentRoot, ErrorLog and CustomLog are changed from the default settings
function copy_reqs {
    find /var/www/$ARG 2> /dev/null
    sed "s/It works!/$ARG/" /var/www/index.html > /var/www/$ARG/index.html
    echo "Replaced the default index.html header with the one in the original argument!"

    find /etc/apache2/sites-available/$ARG 2> /dev/null
    sed -e "s@ServerAdmin webmaster\@localhost@ServerAdmin webmaster\@$ARG@" -e "0,/^$/s/^$/\tServerName $ARG/" -e "s@DocumentRoot /var/www@DocumentRoot /var/www/$ARG@" -e "s@ErrorLog \${APACHE_LOG_DIR}\/error.log@ErrorLog \${APACHE_LOG_DIR}/error-$ARG.log@" -e "s@CustomLog \${APACHE_LOG_DIR}/access.log@CustomLog \${APACHE_LOG_DIR}/access-$ARG.log@" /etc/apache2/sites-available/default > /etc/apache2/sites-available/$ARG
    echo "Finished changing the values in the configuration file!"
}

# Function enables the website and reloads apache2
function reload {
    a2ensite $ARG
    service apache2 reload 2> /dev/null
    echo "Services reloaded."
}

count_args $1
check_apache
check_name $1
check_dir $1
copy_reqs $1
reload $1

echo "Finished script $0"
