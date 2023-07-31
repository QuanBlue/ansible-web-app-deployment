# Load environment variables
source ./aws-ec2/.env

declare -A AWS_CONFIG=(
   [region]=${AWS_REGION:-"ap-southeast-1"}
   [output]="table"
)

declare -A AWS_CREDENTIALS=(
   [aws_access_key_id]=${AWS_ACCESS_KEY_ID}
   [aws_secret_access_key]=${AWS_SECRET_ACCESS_KEY}
)

export AMI_ID=${AMI_ID:-"ami-0df7a207adb9748c7"}
export INSTANCE_NAME=${INSTANCE_NAME:-"quanblue"}
export INSTANCE_TYPE=${INSTANCE_TYPE:-"t2.micro"}
export KEY_PAIR_NAME=${KEY_PAIR_NAME:-"quanblue_key_pair"}
export SECURITY_GROUP_NAME=${SECURITY_GROUP_NAME:-"quanblue_sg"}
export AWS_CONFIG
export AWS_CREDENTIALS
