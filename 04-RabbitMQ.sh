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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding rabbitmq repo"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "Installing erlang and rabbitmq-server"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "Enable and start rabbitmq-server"
 
rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then
      rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
      validate $? "creating rabbitmq user for roboshop"
else
    echo -e "$(timestamp) [INFO] rabbitmq user for roboshop already exists.. ${Y}SKIPPING${N}"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "creating rabbitmq user for roboshop"

echo "$(timestamp) [INFO] Srcipt completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed execution===="| tee -a $logs_file