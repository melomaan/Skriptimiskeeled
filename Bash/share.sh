#!/bin/bash
# Üllar Seerme
# Script creates a new file server and shares the folder to a group 
# under a certain share name. The folder, group name and share name 
# are supplied by passing them as arguments.
export LC_ALL=C
FOLDER=$1
GROUP=$2

# Function checks if Samba is installed, if not then it installs it
function check_install {
    dpkg -s samba > /dev/null

    if [ $? != 0 ]; then
        sudo apt-get update > /dev/null
        sudo apt-get -y install samba > /dev/null
    fi
}

# Function checks if the script was ran under root permissions by looking at the User ID
function check_uid {
    if [ "$UID" != "0" ]; then
        echo "Script $0 needs to be ran as root"
        exit 1
    fi
}

# Function checks the number of arguments given
function count_args {
    # If the no. of arguments is correct (ie three), then the last one is the share name
    if [ $# == 3 ]; then
        SHARE=$3
    # If the no. of arguments is two, then the basename of the first argument is the share name
    elif [ $# == 2 ]; then
        SHARE=$(basename $FOLDER)
    else
        echo "Number of arguments too small. Enter accordingly: "
        echo "$0 FOLDER GROUP [SHARE NAME]"
        exit 1
    fi
}

# Function checks if the folder that is to be shared even exists, if not then it creates it
function check_folder {
    if [ ! -d $FOLDER ]; then
        echo "Such a folder does not exist. Will create folder."
        mkdir -p "$FOLDER"
    fi
}

# Function checks if the group that is to be shared to even exists, if not then it creates it
function check_group {
    getent group $GROUP
    if [ $? != 0 ]; then
        echo "Such a group does not exist. Will create group."
        groupadd "$GROUP"
    fi
}

# Function checks the smb.conf file for an existing share with the same name
function check_share {
    grep -E "^\[$SHARE]$" /etc/samba/smb.conf
}

# If the last action was a success then a copy is created from the original .conf file and all 
# changes are written to that file
function create_share {
    if [ $? != 0 ]; then
        cp /etc/samba/smb.conf /etc/samba/smb_copy.conf
        echo "# Share named \"$SHARE\"
[$SHARE]
    path = $FOLDER
    read only = no
    valid users = @$SHARE
    force group = $SHARE
    create mask = 770
    directory mask = 770" >> /etc/samba/smb_copy.conf
    else
        echo "Such a share already exists under the name $SHARE!"
    fi
}

# Function checks the integrity of the copied configuration file and if no errors occurred, 
# then the changes are written to the original configuration file and smbd services are reloaded
function test_reload {
    testparm -s  /etc/samba/smb_copy.conf > /dev/null
    if [ $? == 0 ]; then
        cp /etc/samba/smb_copy.conf /etc/samba/smb.conf
    else
        echo "An error occurred, changes will persist in the copy!"
    fi

    service smbd reload 2> /dev/null
    echo "Services reloaded."
}

check_install
check_uid
count_args $@
check_folder $1
check_group $2
check_share $3
create_share $3
test_reload

echo "Sharing \"$FOLDER\" to group \"$GROUP\" with share name \"$SHARE\""
