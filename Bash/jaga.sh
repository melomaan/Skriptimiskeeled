#!/bin/bash
# Üllar Seerme, A21
# 04.03.2014
# Skript kontrollib loob uue failiserveri ning jagab etteantud kausta etteantud grupile kasutaja poolt valitud share'ina.
export LC_ALL=C
KAUST=$1
GRUPP=$2

# Funktsioon kontrollib Samba olemasolu ning vajaduse korral paigaldab.
function check_install {
    dpkg -s samba > /dev/null

    if [ $? != 0 ]; then
        sudo apt-get update > /dev/null
        sudo apt-get -y install samba > /dev/null
    fi
}

# Funktsioon kontrollib, kas skript on käivitatud juurkasutajana vaadates User ID-d.
function check_uid {
    if [ "$UID" != "0" ]; then
        echo "Skript $0 tuleb käivitada juurkasutajana"
        exit 1
    fi
}

# Funktsioon kontrollib skriptile antud sisendite arvu.
function count_args {
    # Juhul, kui sisendite arv on õige, siis viimane argument on ka share'i nimi
    if [ $# == 3 ]; then
        SHARE=$3
    # Juhul, kui sisendeid on ainult kaks, siis esimese sisendi järgi võetakse share'i nimi
    elif [ $# == 2 ]; then
        SHARE=$(basename $KAUST)
    else
        echo "Parameetrite arv liiga väike. Argumendid sisestada järgnevalt: "
        echo "$0 KAUST GRUPP [SHARE_NIMI]"
        exit 1
    fi
}

# Funktsioon kontrollib jagatava kausta olemasolu ning kui seda ei ole, siis see luuakse.
function check_folder {
    if [ ! -d $KAUST ]; then
        echo "Sellist kausta ei eksisteeri. Loon kausta."
        mkdir -p "$KAUST"
    fi
}

# Funktsioon kontrollib gruppi olemasolu ning kui seda ei ole, siis see luuakse.
function check_group {
    getent group $GRUPP
    if [ $? != 0 ]; then
        echo "Sellist gruppi ei eksisteeri. Loon gruppi."
        groupadd "$GRUPP"
    fi
}

# Funktsioon kontrollib, kas smb.conf failis asub sisendina antud share'i nimi kasutades regulaaravaldist.
function check_share {
    grep -E "^\[$SHARE]$" /etc/samba/smb.conf
}

# Juhul, kui eelnev toiming õnnestus, siis tehakse koopia originaal smb.conf failist ning kirjutatakse vastavad muudatused sinna.
function create_share {
    if [ $? != 0 ]; then
        cp /etc/samba/smb.conf /etc/samba/smb_copy.conf
        echo "# Share named \"$SHARE\"
[$SHARE]
    path = $KAUST
    read only = no
    valid users = @$SHARE
    force group = $SHARE
    create mask = 770
    directory mask = 770" >> /etc/samba/smb_copy.conf
    else
        echo "Share juba eksisteerib nime all $SHARE!"
    fi
}

# Funktsioon kontrollib smb.conf koopiafaili ning juhul, kui seal vigu ei esinenud, siis kopeeritakse muudatused originaal smb.conf faili ja taaskäivitatakse teenus.
function test_reload {
    testparm -s  /etc/samba/smb_copy.conf > /dev/null
    if [ $? == 0 ]; then
        cp /etc/samba/smb_copy.conf /etc/samba/smb.conf
    else
        echo "Tekkis tõrge, muudatused jäävad koopiasse!"
    fi

    service smbd reload 2> /dev/null
    echo "Teenused taaskäivitatud."
}

check_install
check_uid
count_args $@
check_folder $1
check_group $2
check_share $3
create_share $3
test_reload

echo "Jagan kausta \"$KAUST\" grupile \"$GRUPP\" share'ina \"$SHARE\""
