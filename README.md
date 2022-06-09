# Mysql & Phpmyadmin installer

Bash script for installing mysql & phpmyadmin (optional) only for Debian 11

## 1. Requirements
1)
| OS    | Distribution | VERSION |
| ----- | :----------: | ------- |
| Linux |    Debian    | 11      |

2) Superuser rights

3) Mysql dump in directory with script. File must be call `new_db.sql`

## 2. Project configuration

Start by cloning this project on your workstation.

```sh
git clone git@github.com:vlmaslennikov/mysql-phpmyadmin.git
```

Run script `mysql-phpmyadmin-install.sh` with superuser rights

```sh
cd ./mysql-phpmyadmin
sudo ./mysql-phpmyadmin-install.sh [ARGS...]
```
 
### First argument: 
 Should be called  `'mysql'` 
    
If you want to set a password for mysql the first argument must be `mysql=password` where `'password'` is your mysql user password, otherwise the password will be automatically generated and displayed after the successful completion of the installation script


 ### Second argument (optional) :  
 If you want to install phpmyadmin must be  `'phpmyadmin'` 
   
If you want to set a password for phpmyadmin the first argument must be `phpmyadmin=password`  where `'password'` is your phpmyadmin user password, otherwise the password will be automatically generated and displayed after the successful completion of the installation script

### Options:
 ```-h   ```       display  help end exit 


  
 Upon successful completion of the installation script, the user credentials and connection information will be displayed in the console

 ``` 
 Installation and configuration of all components was successful !

MYSQL ROOT NAME - root
MYSQL ROOT PASSWORD - root
MYSQL USER NAME - newuser
MYSQL USER PASSWORD - password1
MYSQL DB NAME - new_db
MYSQL port - 3306
ALLOWED IP ADRESS FOR MYSQL - 127.0.0.1

PHPMYADMIN USER NAME - newuser
PHPMYADMIN USER PASSWORD - password2
PHPMYADMIN URL - http://localhost/phpmyadmin/
 ```
## 3. Useful links
[Mysql Documentation]() \
[Phpmyadmin Documentation]()



  