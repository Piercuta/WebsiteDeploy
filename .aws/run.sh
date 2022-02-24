#!/usr/bin/env bash
#title          :run.sh
#description    :This script will deploy LAUNCH BAM triggers
#author		    :fgrivillers
#date           :20190809
#version        :0.1
#usage		    :bash run.sh [OPTIONS]
#options        :-v for verbose output
#                -p to switch role to another account
#                -r for specify the region (default eu-west-1)
#                -e precise the name of the environment (default PROD)
#                -b branch of the repo bam (default master)
#                -c specify to use only PREM-BAM account
#==============================================================================
VERBOSE=false
DEBUG="info"
REGION="eu-west-1"
BRANCH="master"
ENV="PROD"
CUST="PC"

while getopts "vp:r:e:b:c:t:" option
do
    case "${option}"
        in
        v) VERBOSE=true && DEBUG="debug";;
        p) PROFILE="--profile ${OPTARG}";;
        f) REGION=${OPTARG};;
        e) ENV=${OPTARG^^};;
        b) BRANCH=${OPTARG};;
        c) CUST="PC";;
		t) TOKEN=${OPTARG};;
    esac
done

echo $REGION
echo $ENV
echo $BRANCH
echo $TOKEN

AWS_DEBUG="--region ${REGION} ${PROFILE}"
TEMPLATE="template.yml"
PACKAGED_TEMPLATE="packaged-${TEMPLATE}"
BUCKET_CODE="${CUST,,}-${ENV,,}-deploy-website-code"
STACK_NAME="${CUST}-${ENV}-DEPLOY-WEBSITE"

LOG() {
    if [ $VERBOSE = true ]; then
        echo "${1}"
    fi
}

LOG_AND_EXEC() {
    LOG "${1}"
    ${1}
}

create_bucket_if_not_exists() {
    if aws ${AWS_DEBUG} s3api head-bucket --bucket ${1} 2>/dev/null;
        then
            LOG "Bucket ${1} already exists"
        else
            LOG "Bucket ${1} doesn't exists, so it creation was request"
            LOG_AND_EXEC "aws ${AWS_DEBUG} s3 mb s3://${1}"
    fi
}

echo "Create bucket ${BUCKET_CODE} if not exists"
create_bucket_if_not_exists ${BUCKET_CODE}

echo "Package cloudformation in bucket ${BUCKET_CODE}"
LOG_AND_EXEC "aws ${AWS_DEBUG} cloudformation package \
    --template-file ${TEMPLATE} \
    --s3-bucket ${BUCKET_CODE} \
    --output-template-file ${PACKAGED_TEMPLATE}"

echo "Deploy cloudformation ${STACK_NAME}"
LOG_AND_EXEC "aws ${AWS_DEBUG} cloudformation deploy \
    --template-file ${PACKAGED_TEMPLATE} \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        Cust=${CUST} \
        Env=${ENV} \
        EnvLC=${ENV,,} \
        CustLC=${CUST,,} \
		Token=${TOKEN} \
        Branch=${BRANCH}"
