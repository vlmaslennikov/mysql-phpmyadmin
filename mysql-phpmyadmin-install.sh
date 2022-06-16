#!/bin/bash

Help(){
   echo
   echo "Script for installing mysql and/or phpmyadmin only for DEBIAN 11"
   echo "For the script to work successfully, you must use SUPERUSER RIGHTS to run it"
   echo
   echo "Usage: sudo ./[THIS SCRIPT] [ARGS...]"
   echo
   echo "IF YOU WANT TO INSTALL MYSQL ( WITH OR WITHOUT PHPMYADMIN ):"
   echo
   echo "Arguments:"
   echo "    First argument:  should be called [mysql] "
   echo 
   printf "If you want to set a password for mysql \nthe first argument must be mysql=password \nwhere 'password' is your mysql user password, \notherwise the password will be automatically generated \nand displayed after the successful completion \nof the installation script\n\n"
   printf "MYSQL dump or exits database must be called 'new_db'\n\n"
   printf "    Second argument:  should be called [root] \n"
   printf "If you want to set a password for mysql root user \nthe second argument must be root=password \nwhere 'password' is your mysql root user password, \notherwise the password will be automatically generated \nand displayed after the successful completion \nof the installation script\n\n"
   printf "    Third argument (optional) :  if you want to install phpmyadmin must be called [phpmyadmin]\n"
   printf "If you want to set a password for phpmyadmin \nthe first third must be phpmyadmin=password \nwhere 'password' is your phpmyadmin user password, \notherwise the password will be automatically generated \nand displayed after the successful completion \nof the installation script\n\n"
   printf "IF YOU WANT TO INSTALL ONLY PHPMYADMIN:\n\n"
   printf "Arguments:\n"
   printf "    First argument: should be called [phpmyadmin] \n"
   printf "If you want to set a password for phpmyadmin \nthe first third must be phpmyadmin=password \nwhere 'password' is your phpmyadmin user password, \notherwise the password will be automatically generated \nand displayed after the successful completion \nof the installation script\n" 
   printf "    Second argument:  should be mysql user name \n"
   printf "    Third argument:  should be mysql user password \n"
   printf "    Fourth argument:  should be mysql database name \n"
   printf "    Fifth argument:  should be  mysql host \n"
   printf "Options:\n"
   echo "     -h     display this help end exit"

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

if [ $OS != "debian" ] || [ $OS_VERSION != '"11"' ]

    then
        echo "Error: Invalid OS or OS VERSION ; Must be only DEBIAN 11 !"
        exit ;
fi

InstallPhpMyAdmin(){

    if [[ $( cut -f1 -d '=' <<< $2 ) = "phpmyadmin" ]]
        
        then 
            if grep -q "=" <<< $2;

                then
                    PHPMYADMIN_USER_PASSWORD=$( cut -d '=' -f2 <<< $2 )
                else
                    PHPMYADMIN_USER_PASSWORD=$(openssl rand -base64 9)
            fi

            export DEBIAN_FRONTEND=noninteractive
            apt-get -yq install phpmyadmin

            echo
            echo 'Installing phpmyadmin was successful !'

                
            # MYSQL_SOCKET=$(mysql -uroot -e "status" | grep "^UNIX socket" | cut -d ':' -f2 | sed -e 's/^[[:space:]]*//')
            # sed -i "$ a \ \n\$cfg['Servers'][\$i]['socket'] = '${MYSQL_SOCKET}';" /etc/phpmyadmin/config.inc.php

            sed -i "$ a \ \nInclude /etc/phpmyadmin/apache.conf " /etc/apache2/apache2.conf

            sed -i "$ a \ \n\$i++; \n\$cfg['Servers'][\$i]['host'] = '${6}'; \n\$cfg['Servers'][\$i]['user'] = '${3}'; \n\$cfg['Servers'][\$i]['password'] = '${PHPMYADMIN_USER_PASSWORD}'; \n\$cfg['Servers'][\$i]['auth_type'] = 'config';" /etc/phpmyadmin/config.inc.php

            sed -i "/\$dbuser/d" /etc/phpmyadmin/config-db.php
            sed -i "/\$dbpass/d" /etc/phpmyadmin/config-db.php
            sed -i "/\$dbname/d" /etc/phpmyadmin/config-db.php
            sed -i "/\$dbserver/d" /etc/phpmyadmin/config-db.php

            sed -i "$ a \ \n\$dbuser='${3}';" /etc/phpmyadmin/config-db.php
            sed -i "$ a \ \n\$dbpass='${4}';" /etc/phpmyadmin/config-db.php
            sed -i "$ a \ \n\$dbname='${5}';" /etc/phpmyadmin/config-db.php
            sed -i "$ a \ \n\$dbserver='${6}';" /etc/phpmyadmin/config-db.php

            PHP_V=$(php -v | grep "^PHP" | cut -d ' ' -f2 | rev |cut -d"." -f2- |rev)

            apt install libapache2-mod-php${PHP_V}

            systemctl restart apache2
                    
            echo
            echo 'Connecting phpmyadmin to mysql was successful !'

            if [[ $1  = "single" ]] 

                then 
                    echo "PHPMYADMIN USER PASSWORD - ${PHPMYADMIN_USER_PASSWORD}"
                    echo "PHPMYADMIN URL - http://localhost/phpmyadmin/" 
                    exit
            fi
    fi

}


InstallPhpMyAdmin "single" $1 $2 $3 $4 $5 

MYSQL_ARG=$( cut -f1 -d '=' <<< $1 )
MYSQL_ROOT_ARG=$( cut -f1 -d '=' <<< $2 )
PHPMYADMIN_ARG=$( cut -f1 -d '=' <<< $3 )

IP_ADRESS='127.0.0.1'
DB_NAME='new_db'
USER_NAME='newuser'
LOCATION=`pwd`

if [ $MYSQL_ARG != 'mysql' ] || [ $MYSQL_ROOT_ARG != 'root' ]

    then 
        echo "Error: Invalid 1st or 2nd argument"
        exit ;

    else 
        if grep -q "=" <<< $1;
            then
                MYSQL_USER_PASSWORD=$( cut -d '=' -f2 <<< $1 )
                MYSQL_ROOT_PASSWORD=$( cut -d '=' -f2 <<< $2 )
            else
                MYSQL_USER_PASSWORD=$(openssl rand -base64 9)
                MYSQL_ROOT_PASSWORD=$(openssl rand -base64 9)
        fi
fi

cd /tmp 

apt-get -y update

wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb 

export DEBIAN_FRONTEND=noninteractive 

dpkg -i  mysql-apt-config* 

apt update 

apt -yq install mysql-server 

sed -i "$ a \ \nbind-address = ${IP_ADRESS}" /etc/mysql/mysql.conf.d/mysqld.cnf

mysql -uroot -e "CREATE USER ${USER_NAME}@${IP_ADRESS} IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"

if ! $( mysql -uroot  -e "use ${DB_NAME}");

    then 
        cd $LOCATION
        mysql -uroot  -e "CREATE DATABASE ${DB_NAME};"
        mysql -uroot  -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${USER_NAME}'@'${IP_ADRESS}';"
        mysql -uroot  -e "FLUSH PRIVILEGES;"
        mysql -uroot  ${DB_NAME} < ${DB_NAME}.sql ;
        echo
        echo "Mysql dump loaded successfully !"
        echo

fi

echo
echo 'Installing and configuring mysql was successful !'
echo

if [[ $PHPMYADMIN_ARG = "phpmyadmin" ]]
        
    then 
        InstallPhpMyAdmin "multipurpose" $3 $USER_NAME $MYSQL_USER_PASSWORD $DB_NAME $IP_ADRESS
fi

systemctl stop mysql

mysqld_safe --skip-grant-tables&

PID=$!
kill $PID

systemctl start mysql

mysql --user=root mysql <<MYSQL_SCRIPT

UPDATE mysql.user SET authentication_string=null WHERE User='root';

flush privileges;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';

flush privileges;

MYSQL_SCRIPT
echo
echo 'Final setting mysql done successfully !'
echo
echo "Installation and configuration of all components was successful !"
echo
echo "MYSQL ROOT NAME - root"
echo "MYSQL ROOT PASSWORD - ${MYSQL_ROOT_PASSWORD}"
echo "MYSQL USER NAME - ${USER_NAME}"
echo "MYSQL USER PASSWORD - ${MYSQL_USER_PASSWORD}"
echo "MYSQL DB NAME - ${DB_NAME}"
echo "MYSQL port - 3306" 
echo "ALLOWED IP ADRESS FOR MYSQL - ${IP_ADRESS}"
echo
if [[ $PHPMYADMIN_ARG = "phpmyadmin" ]]
   then
       echo "PHPMYADMIN USER PASSWORD - ${PHPMYADMIN_USER_PASSWORD}"
       echo "PHPMYADMIN URL - http://localhost/phpmyadmin/" 
fi



 