# #!/bin/bash

# ami_id="ami-0055977a6e828a4f4"
# instance_type="t3.micro"
# domain_name="shariffdevops.online"
# hosted_zone_id="Z03986291U87DG3HBUGU4"

# for instance in $@
# do
# echo "Creating instance: $instance"

# instance_id=$(aws ec2 run-instances \
# --image-id $ami_id \
# --instance-type $instance_type \
# --security-groups-id "sg-088c500f72e42a729" "roboshop-$instance"\
# --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
# --query 'Instances[0].InstanceId' \
# --output text
# )

# echo "$intance ID: $instance_id"
# done


#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="shariffdevops.online"
hosted_zone_id="Z03986291U87DG3HBUGU4"

for instance in $@
do
    echo "Creating instance: $instance"

    instance_id=$(aws ec2 run-instances \
            --image-id $ami_id \
            --instance-type $instance_type \
            --security-groups "roboshop-common" "roboshop-$instance" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
            --query 'Instances[0].InstanceId' \
            --output text
    )