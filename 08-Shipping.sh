#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="shariffdevops.online"
scripts_dir=$(dirname "$(realpath "$0")")
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
    date "+%F_%T"
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

dnf module enable maven:3.9 -y &>> $logs_file
dnf install maven java-25-openjdk-devel -y &>> $logs_file
validate $? "Installing Java and Maven"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds" | tee -a $logs_file
echo "$(timestamp) [INFO] ====Script completed execution====" | tee -a $logs_file