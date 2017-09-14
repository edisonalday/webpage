#!/bin/bash -e

# Script to launch CML-LOG instance

NAME=${NAME:-"PRE-WEB-01A"} # Instance name in AWS console
REGION=${REGION:-"us-east-1"} # Region
VPC_ID=${SVPC_ID:-"vpc-2fbdb556"}
SUBNET_ID=${SUBNET_ID:-"subnet-05f2db29"} # VPC Subnet
INSTANCE_TYPE=${INSTANCE_TYPE:-"t2.medium"}  # Instance type
VOLUME_SIZE=${VOL:-10}  # Root size
VOLUME_TYPE=${TYPE:-"GP2"}  # Root size
IAM_PROFILE=${IAM_PROFILE:-"PRE-EC2"} # IAM Role
SECURITY_GROUP_ID=${SECURITY_GROUP_ID:-"sg-7c42391b"} # Security group
ENVIRONMENT=${ENVIRONMENT:-"PRE"}
VPC=${VPC:-"PRE"}
PURPOSE=${PURPOSE:-"Web"}


JQ=$(which jq)
if [[ $? -eq 1 ]]; then
echo "You need to install jq"
exit 1
fi
AWS=$(which aws)
if [[ $? -eq 1 ]]; then
echo "You need to install awscli tools and configure it (aws configure)"
exit 1
fi
echo ""
echo "Launching $NAME instance with:"
echo ""
echo "  NAME               $NAME"
echo "  REGION             $REGION"
echo "  VPC ID             $VPC_ID"
echo "  SUBNET ID          $SUBNET_ID"
echo "  INSTANCE TYPE      $INSTANCE_TYPE"
echo "  INSTANCE STORAGE   $VOLUME_SIZE"
echo "  IAM PROFILE        $IAM_PROFILE"
echo "  SECURITY GROUP     $SECURITY_GROUP_ID"
echo "  ENVIRONMENT        $ENVIRONMENT"
echo "  PURPOSE            $PURPOSE"
ami_id=$(aws ec2 describe-images --region ap-southeast-1 --filters "Name=tag:Role,Values=Logstash,Name=tag:Name,Values=CML-LOG-01A,Name=tag:Created,Values=20170419-1492594214" | jq '.Images | sort_by(.Creation_date) | .[0].ImageId' | sed 's/"//g')
echo "  AMI                $ami_id"
# echo "Launching $NAME instance..."
instance=$(aws ec2 run-instances --iam-instance-profile Name=$IAM_ROLE --region $REGION \
--image-id $ami_id \
--subnet-id $SUBNET_ID \
--instance-type $INSTANCE_TYPE \
--block-device-mappings file://mapping.json \
--security-group-ids $SECURITY_GROUP_ID \
--associate-public-ip-address\
)
instance_id=$(echo $instance | jq '.Instances[0].InstanceId' | sed 's/"//g')
#echo ""
echo "  INSTANCE ID        $instance_id"
echo ""
echo "Tagging $NAME instance ..."
echo ""
aws ec2 create-tags --region $REGION --resources $instance_id --tags Key=Name,Value=$NAME
aws ec2 create-tags --region $REGION --resources $instance_id --tags Key=Environment,Value=$ENVIRONMENT
aws ec2 create-tags --region $REGION --resources $instance_id --tags Key=VPC,Value=$VPC
aws ec2 create-tags --region $REGION --resources $instance_id --tags Key=Purpose,Value=$PURPOSE

echo "Done"
