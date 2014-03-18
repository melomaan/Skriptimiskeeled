#!/bin/bash
# Üllar Seerme, A21
# 04.03.2014
# Skript loob uue kodulehe vastavalt selle aadressiga, mida kasutaja käsureale argumendiks sisestab.
export LC_ALL=C

# Funktsioon kontrollib, kas parameetrite arv on õige
function count_args {
    if [ $# == 1 ]; then
        ARG=$1
    else
        echo "Sisesta õige arv argumente!"
        exit 1
    fi
}

# Funktsioon kontrollib apache2 serveri olemasolu ning vajadusel paigaldab selle.
function check_apache {
    dpkg -s apache2 >> /dev/null

    if [ $? == 0 ]; then
        echo "Apache on juba paigaldatud!"
    else
        sudo apt-get update > /dev/null
        sudo apt-get -y install apache2 > /dev/null
        echo "Paigaldasin Apache'i!"
    fi
}

# Funktsioon kontrollib, kas /etc/hosts failis on vastav aadress juba olemas ning kui ei ole, siis lisab selle aadressiga 127.0.0.1.
function check_name {
    grep -E "^127.0.0.1 $ARG" /etc/hosts 2> /dev/null

    if [ $? == 0 ]; then
        echo "Nimelahendus peaks toimima. Proovi pingida!"
    else
        echo "127.0.0.1 $ARG" >> /etc/hosts
        echo "Lisasin aadressi /etc/hosts kausta!"
    fi
}

# Funktsioon kontrollib, kas /var/www kaustas on olemas vastava aadressiga kataloog ning kui ei ole, siis lisab selle.
function check_dir {
    ls /var/www/"$ARG" 2> /dev/null

    if [ $? == 0 ]; then
        echo "Veebisaidi kodukataloog on olemas!"
    else
        mkdir /var/www/"$ARG"
        echo "Lõin kataloogi $ARG kausta /var/www!"
    fi
}

# Funktsioon kopeerib ümber default index.html faili ja muudab ümber päise. Lisaks sellele tehakse muudatused seadistusfailides, kus muudetakse ServerAdmin, ServerName, DocumentRoot, ErrorLog ja CustomLog read.
function copy_reqs {
    find /var/www/$ARG 2> /dev/null
    sed "s/It works!/$ARG/" /var/www/index.html > /var/www/$ARG/index.html
    echo "Asendasin default index.html päise parameetri omaga!"

    find /etc/apache2/sites-available/$ARG 2> /dev/null
    sed -e "s@ServerAdmin webmaster\@localhost@ServerAdmin webmaster\@$ARG@" -e "0,/^$/s/^$/\tServerName $ARG/" -e "s@DocumentRoot /var/www@DocumentRoot /var/www/$ARG@" -e "s@ErrorLog \${APACHE_LOG_DIR}\/error.log@ErrorLog \${APACHE_LOG_DIR}/error-$ARG.log@" -e "s@CustomLog \${APACHE_LOG_DIR}/access.log@CustomLog \${APACHE_LOG_DIR}/access-$ARG.log@" /etc/apache2/sites-available/default > /etc/apache2/sites-available/$ARG
    echo "Lõpetasin muudatused seadistusfailides!"
}

# Funktsioon käivitab (enable'ib) lehe ning taaskäivitab apache2 serveri.
function reload {
    a2ensite $ARG
    service apache2 reload 2> /dev/null
    echo "Teenused taaskäivitatud."
}

count_args $1
check_apache
check_name $1
check_dir $1
copy_reqs $1
reload $1

echo "Lõpetasin skripti $0"