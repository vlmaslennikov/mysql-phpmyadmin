#!/bin/bash

Help()
{
   echo
   echo "Script for installing mysql and phpmyadmin(optional) only for DEBIAN 11"
   echo "For the script to work successfully, you must use SUPERUSER RIGHTS to run it"
   echo
   echo "Usage: sudo ./[THIS SCRIPT] [ARGS...]"
   echo
   echo "Arguments:"
   echo "    First argument:  should be [mysql] "
   echo 
   printf "If you want to set a password for mysql \nthe first argument must be mysql=password \nwhere 'password' is your mysql user password, \notherwise the password will be automatically generated \nand displayed after the successful completion \nof the installation script\n"
   printf "MYSQL dump or exits database must be call 'new_db'\n"
   echo "    Second argument (optional) :  if you want to install phpmyadmin must be [phpmyadmin]"
   echo
   printf "If you want to set a password for mysql \nthe first argument must be phpmyadmin=password \nwhere 'password' is your phpmyadmin user password, \notherwise the password will be automatically generated \nand displayed after the successful completion \nof the installation script\n"
   echo "Options:"
   echo "-h     display this help end exit"
}

while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
     \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done

OS=$(cut -d '=' -f2 <<< $(grep '^ID=' /etc/os-release ))
OS_VERSION=$(cut -d '=' -f2 <<< $(grep '^VERSION_ID' /etc/os-release ))

if [ $OS != "debian" ] && [ $OS_VERSION != '"11"' ]

    then
        echo "Error: Invalid OS or OS VERSION ; Must be only DEBIAN 11 !"
        exit ;
fi

MYSQL_ARG=''
PHPMYADMIN_ARG=''
MYSQL_USER_PASSWORD=''
PHPMYADMIN_USER_PASSWORD=''
MYSQL_ARG=$( cut -f1 -d '=' <<< $1 )

    if [[ $MYSQL_ARG != 'mysql' ]]

        then 
            echo "Error: Invalid 1st argument"
            exit ;

        else 
            MYSQL_USER_PASSWORD=$( cut -d '=' -f2 <<< $1 )
    fi

PHPMYADMIN_ARG=$( cut -f1 -d '=' <<< $2 )
RANDOM_MYSQL_PASSWORD="$(openssl rand -base64 9)"
RANDOM_PHPMYADMIN_PASSWORD="$(openssl rand -base64 9)"

MYSQL_ROOT_PASSWORD='root'

DB_NAME='new_db'
USER_NAME='newuser'
IP_ADRESS='127.0.0.1'
LOCATION=`pwd`


cd /tmp 

apt-get -y update

wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb 

export DEBIAN_FRONTEND=noninteractive 

dpkg -i  mysql-apt-config* 

apt update 

apt -yq install mysql-server 

mysqld_safe --skip-grant-tables&

PID=$!
kill $PID

mysql --user=root mysql <<MYSQL_SCRIPT

UPDATE mysql.user SET authentication_string=null WHERE User='root';

flush privileges;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';

flush privileges;

MYSQL_SCRIPT

sed -i "$ a \ \nbind-address = ${IP_ADRESS}" /etc/mysql/mysql.conf.d/mysqld.cnf

if [ -z $MYSQL_USER_PASSWORD ]

    then 
        MYSQL_USER_PASSWORD=$RANDOM_MYSQL_PASSWORD

fi

mysql -uroot --password='root' -e "CREATE USER ${USER_NAME}@${IP_ADRESS} IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"

if ! $( mysql -uroot --password='root' -e "use ${DB_NAME}");

    then 
        cd $LOCATION
        mysql -uroot --password='root' -e "CREATE DATABASE ${DB_NAME};"
        mysql -uroot --password='root' -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${USER_NAME}'@'${IP_ADRESS}';"
        mysql -uroot --password='root' -e "FLUSH PRIVILEGES;"
        mysql -uroot --password='root' ${DB_NAME} < ${DB_NAME}.sql ;
        echo
        echo "Mysql dump loaded successfully !"
        echo

fi
echo
echo 'Installing and configuring mysql was successful !'
echo
if [[ $PHPMYADMIN_ARG = "phpmyadmin" ]]
        
    then 
        PHPMYADMIN_USER_PASSWORD=$( cut -d '=' -f2 <<< $2 )

        export DEBIAN_FRONTEND=noninteractive
        apt-get -yq install phpmyadmin

        sed -i "/<Directory \/usr\/share\/phpmyadmin>/a \ Order Deny,Allow \ \n Deny from all \ \n Allow from ${IP_ADRESS}" /etc/phpmyadmin/apache.conf

 
        if [ -z $PHPMYADMIN_USER_PASSWORD ]

            then 
                PHPMYADMIN_USER_PASSWORD=$RANDOM_PHPMYADMIN_PASSWORD

        fi


        sed -i "/<Directory \/usr\/share\/phpmyadmin>/a \ Order Deny,Allow \ \n Deny from all \ \n Allow from ${IP_ADRESS}" /etc/phpmyadmin/apache.conf
        sed -i "$ a \ \n\$i++; \n\$cfg['Servers'][\$i]['host'] = ${IP_ADRESS}; \n\$cfg['Servers'][\$i]['user'] = ${USER_NAME}; \n\$cfg['Servers'][\$i]['password'] = ${PHPMYADMIN_USER_PASSWORD}; \n\$cfg['Servers'][\$i]['auth_type'] = 'config';" /etc/phpmyadmin/config.inc.php
        sed -i "$ a \ \nInclude /etc/phpmyadmin/apache.conf " /etc/apache2/apache2.conf


        sed -i "/\$dbuser/d" /etc/phpmyadmin/config-db.php
        sed -i "/\$dbpass/d" /etc/phpmyadmin/config-db.php
        sed -i "/\$dbname/d" /etc/phpmyadmin/config-db.php

        sed -i "$ a \ \n\$dbuser='${USER_NAME}'" /etc/phpmyadmin/config-db.php
        sed -i "$ a \ \n\$dbname='${DB_NAME}'" /etc/phpmyadmin/config-db.php
        sed -i "$ a \ \n\$dbpass='${MYSQL_USER_PASSWORD}'" /etc/phpmyadmin/config-db.php

        systemctl restart apache2
        echo
        echo 'Installing and phpmyadmin mysql was successful !'
fi 
 echo
 echo "Installation and configuration of all components was successful !"
 echo
 echo "MYSQL USER NAME  ${USER_NAME}"
 echo "MYSQL USER PASSWORD  ${MYSQL_USER_PASSWORD}"
 echo "MYSQL DB NAME  ${DB_NAME}"
 echo "MYSQL port - 3306" 
 echo
 if [[ $PHPMYADMIN_ARG = "phpmyadmin" ]]
    then
     echo "PHPMYADMIN USER NAME  ${USER_NAME}"
     echo "PHPMYADMIN USER PASSWORD  ${PHPMYADMIN_USER_PASSWORD}"
     echo "PHPMYADMIN URL - http://localhost/phpmyadmin/" 
fi
 echo "ALLOWED IP ADRESS - ${IP_ADRESS}"

 