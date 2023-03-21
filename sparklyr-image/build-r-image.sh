#!/bin/bash

# Modify these as required. The Docker registry endpoint can be tuned based on your current region from https://docs.aws.amazon.com/general/latest/gr/ecr.html#ecr-docker-endpoints

REGION=$(aws configure get region)
ACCOUNT_ID=$( aws sts get-caller-identity --output text --query 'Account')
REPO_NAME=sagemaker-rstudio-custom

# Create the ECR repository
aws --region ${REGION} ecr create-repository --repository-name ${REPO_NAME}

# Build the image
IMAGE_NAME=sparklyr

aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}

docker build . -t ${IMAGE_NAME} -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_NAME}

# Push image to ECR
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_NAME}

# Role in your account to be used for the SageMaker Image
ROLE_ARN=arn:aws:iam::${ACCOUNT_ID}:role/SageMakerUserExecutionRole

aws --region ${REGION} sagemaker create-image \
    --description "Sparklyr for RStudio on Amazon SageMaker" \
    --display-name "Sparklyr (CPU - R 4.2.0)" \
    --image-name ${IMAGE_NAME} \
    --role-arn ${ROLE_ARN}

aws --region ${REGION} sagemaker create-image-version \
    --image-name ${IMAGE_NAME} \
    --base-image "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_NAME}"

# Verify the image-version is created successfully. Do NOT proceed if image-version is in CREATE_FAILED state or in any other state apart from CREATED.
aws --region ${REGION} sagemaker describe-image-version --image-name ${IMAGE_NAME}

aws --region ${REGION} sagemaker create-app-image-config --app-image-config-name ${IMAGE_NAME}

aws --region ${REGION} sagemaker update-domain --cli-input-json file://update-domain-input.json

