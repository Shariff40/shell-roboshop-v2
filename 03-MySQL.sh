#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ "$user_id" -ne 0 ]; then
    echo "Please run this script with sudo access.."
    exit 1
fi

mkdir -p $logs_folder

echo "Script started evecution at $(date +%F_%T)" &>> $logs_file

timestamp() {
    date +%F_%T
}


validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}.. ${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${2}..${G}SUCCESS${N}" | tee -a $logs_file 
    fi
}
echo "$(timestamp) [INFO]====Script started execution===="| tee -a $logs_file

dnf module enable mysql:8.4 -y &>> $logs_file
dnf install mysql-server -y &>> $logs_file
validate $? "Installing mysql-server"

systemctl enable mysqld &>> $logs_file
systemctl start mysqld
validate $? "Enable and start mysql-server"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "Setting root password for mysql-server"

echo "$(timestamp) [INFO] Srcipt completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed execution===="| tee -a $logs_file