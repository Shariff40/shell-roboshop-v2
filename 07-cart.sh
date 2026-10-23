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

dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf install nodejs -y &>> $logs_file
validate $? "Installing nodejs 24"

id roboshop &>> "$logs_file"
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Creating system user"
else
    echo -e "System user roboshop already exists....${Y}SKIPPING${N}" | tee -a "$logs_file"
fi

rm -rf /app
validate $? "removing old code"

mkdir -p /app
validate $? "Creating app directory"

curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip
validate $? "Downloading cart"

cd /app
unzip /tmp/cart.zip &>> $logs_file
validate $? "unzipping cart"

npm install &>> $logs_file
validate $? "Installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/cart.service"
validate $? "Updating cart service"

cp "$scripts_dir/cart.service" /etc/systemd/system/cart.service
validate $? "Copying cart service"

systemctl daemon-reload
validate $? "Reloading systemd"

systemctl enable cart &>> "$logs_file"
validate $? "Enabling cart"

systemctl start cart &>> "$logs_file"
validate $? "Starting cart"


systemctl restart cart
validate $? "Restarting cart"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds" | tee -a $logs_file
echo "$(timestamp) [INFO] ====Script completed execution====" | tee -a $logs_file