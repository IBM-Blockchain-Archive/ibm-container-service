#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo "Creating Services for blockchain network"
if [ "${1}" == "--with-couchdb" ]; then
    # Use the yaml file with couchdb
    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-couchdb-services.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-couchdb-services.yaml
else
    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml
fi


echo "Creating new Deployment"
if [ "${1}" == "--with-couchdb" ]; then
    # Use the yaml file with couchdb
    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-couchdb.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-couchdb.yaml
else
    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/blockchain.yaml
fi

echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments | grep blockchain | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments | grep blockchain | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
done

if [ "${1}" == "--with-couchdb" ]; then
    echo "Waiting for 15 seconds for peers to settle, as we are running with couchdb"
    sleep 15
fi
