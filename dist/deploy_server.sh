#!/bin/bash
APP_NAME=$1
SERVER=$2
SATEL_DOCKER_USER=$3
SATEL_DOCKER_PASS=$4
CLIENT_DOCKER_USER=$5
CLIENT_DOCKER_PASS=$6
SATEL_REGISTRY=$7
CLIENT_REGISTRY=$8
DOCKERFILE=$9
BRANCH_NAME=${10}
TAG_NAME=${11}

echo "DOCKERFILE=${DOCKERFILE}"

echo "Build Server"
if [[ $SERVER != None ]]
then
    cd $SERVER
    if [[ $CURRENT_BRANCH_NAME == 'main' ]]
    then    
        CLEAN_BRANCH_NAME='main'
    elif [[ -n $TAG_NAME ]]  
    then  
        CLEAN_BRANCH_NAME=$TAG_NAME
    else
        CLEAN_BRANCH_NAME=${CURRENT_BRANCH_NAME////_}
    fi

    cd ..

    echo "Check if the app uses poetry"
    if grep -i "poetry" $DOCKERFILE; then
        EXTRA_ARGUMENTS="--dev"
    fi

    echo "Build and Push branch image to docker"
    if [[ -n $TAG_NAME ]]  
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
    
    export REGISTRY=$REGISTRY
    export CLEAN_BRANCH_NAME=$CLEAN_BRANCH_NAME  
    # need these two for docker up
fi    
