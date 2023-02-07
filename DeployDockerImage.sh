#!/bin/bash
APP_NAME=$1
WORK_DIR=$2
SATEL_DOCKER_USER=$3
SATEL_DOCKER_PASS=$4
CLIENT_DOCKER_USER=$5
CLIENT_DOCKER_PASS=$6
SATEL_REGISTRY=$7
CLIENT_REGISTRY=$8
DOCKERFILE=$9
BRANCH_NAME=${10}
TAG_NAME=${11}


echo "APP_NAME=${APP_NAME}, WORK_DIR=${WORK_DIR}, SATEL_DOCKER_USER=${SATEL_DOCKER_USER}, SATEL_DOCKER_PASS=${SATEL_DOCKER_PASS}, CLIENT_DOCKER_USER=${CLIENT_DOCKER_USER}"
echo "SATEL_REGISTRY=${SATEL_REGISTRY}, CLIENT_REGISTRY=${CLIENT_REGISTRY}, DOCKERFILE=${DOCKERFILE}, BRANCH_NAME=${BRANCH_NAME}, TAG_NAME=${TAG_NAME}"

if [[ -n $WORK_DIR ]]
then
    echo "WORK_DIR ${WORK_DIR}"
    cd $WORK_DIR
fi 
 
echo "Build Server"
if [[ $BRANCH_NAME == 'main' ]]
then    
    CLEAN_BRANCH_NAME='main'
elif [[ -n $TAG_NAME ]]  
then  
    CLEAN_BRANCH_NAME=$TAG_NAME
else
    CLEAN_BRANCH_NAME=${BRANCH_NAME////_} # Replace / in branch name with _ for portainer
fi

echo "Check if the app uses poetry via Dockerfile"
if grep -i "poetry" $DOCKERFILE; then
    EXTRA_ARGUMENTS="--dev"
fi

echo "Build and Push branch image to docker"
if [[ -n $TAG_NAME ]]   # if it's a tag, push to client registry
then
    DOCKER_USER=$CLIENT_DOCKER_USER
    DOCKER_PASS=$CLIENT_DOCKER_PASS
    REGISTRY=$CLIENT_REGISTRY
else
    DOCKER_USER=$SATEL_DOCKER_USER
    DOCKER_PASS=$SATEL_DOCKER_PASS
    REGISTRY=$SATEL_REGISTRY    
fi

echo "${DOCKER_USER} ${DOCKER_PASS} ${REGISTRY}"

docker login --username=$DOCKER_USER --password=$DOCKER_PASS $REGISTRY
docker build -f $DOCKERFILE . -t $REGISTRY/$APP_NAME:$CLEAN_BRANCH_NAME --build-arg DEVFLAG=$EXTRA_ARGUMENTS
docker push $REGISTRY/$APP_NAME:$CLEAN_BRANCH_NAME  

# These outputs are used in other steps/jobs via action.yml
echo "::set-output name=registry::$REGISTRY"
echo "::set-output name=CLEAN_BRANCH_NAME::$CLEAN_BRANCH_NAME"
