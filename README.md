# Mysql & Phpmyadmin installer

Bash script for installing mysql and/or phpmyadmin only for Debian 11

## 1. Requirements
1)
| OS    | Distribution | VERSION |
| ----- | :----------: | ------- |
| Linux |    Debian    | 11      |

2) Superuser rights

3) Mysql dump in directory with script. File must be called `new_db.sql`

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
 
## IF YOU WANT TO INSTALL MYSQL ( WITH OR WITHOUT PHPMYADMIN ):

### First argument: 
 Should be called  `'mysql'` 
  
If you want to set a password for mysql the first argument must be `mysql=password` where `'password'` is your mysql user password, otherwise the password will be automatically generated and displayed after the successful completion of the installation script

### Second argument: 
 Should be called  `'root'` 

If you want to set a password for mysql root user the second argument must be `root=password` where `'password'` is your mysql root user password, otherwise the password will be automatically generated and displayed after the successful completion of the installation script

### Third argument: 
 Should be allowed IP for mysql user
 
If the entered IP is invalid, then the value `127.0.0.1` will be used

### Fourth argument (optional) :  
 If you want to install phpmyadmin must be called `'phpmyadmin'` 
 
If you want to set a password for phpmyadmin the third argument must be `phpmyadmin=password`  where `'password'` is your phpmyadmin user password, otherwise the password will be automatically generated and displayed after the successful completion of the installation script

## IF YOU WANT TO INSTALL ONLY PHPMYADMIN:

### First argument :  
 Should be called `'phpmyadmin'` 

If you want to set a password for phpmyadmin the third argument must be `phpmyadmin=password`  where `'password'` is your phpmyadmin user password, otherwise the password will be automatically generated and displayed after the successful completion of the installation script


### Second argument :  
 Should be mysql user name 

### Third argument :  
 Should be mysql user password

### Fourth argument :  
 Should be mysql database name  

### Fifth argument :  
 Should be mysql host
 
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
MYSQL PORT - 3306
ALLOWED IP FOR MYSQL ROOT - localhost
ALLOWED IP FOR MYSQL USER 'newuser'- 127.0.0.1

PHPMYADMIN USER PASSWORD - password2
PHPMYADMIN URL - http://localhost/phpmyadmin/
 ```
## 3. Useful links
[Mysql Documentation]() \
[Phpmyadmin Documentation]()



