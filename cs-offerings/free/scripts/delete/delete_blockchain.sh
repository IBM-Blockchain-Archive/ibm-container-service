#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/delete' folder"
	exit
fi

echo "Deleting blockchain services"
if [ "$(kubectl get svc | grep couchdb | wc -l | awk '{print $1}')" != "0" ]; then
    # Use the yaml file with couchdb
    echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-couchdb-services.yaml"
    kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-couchdb-services.yaml
else
    echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml"
    kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml
fi

echo "Deleting blockchain deployments"
if [ "$(kubectl get pods -a | grep couchdb | wc -l | awk '{print $1}')" != "0" ]; then
    # Use the yaml file with couchdb
    echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-couchdb.yaml"
    kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-couchdb.yaml
else
    echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain.yaml"
    kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain.yaml
fi

echo "Checking if all deployments are deleted"

NUM_PENDING=$(kubectl get deployments | grep blockchain | wc -l | awk '{print $1}')
while [ "${NUM_PENDING}" != "0" ]; do
	echo "Waiting for all blockchain deployments to be deleted. Remaining = ${NUM_PENDING}"
    NUM_PENDING=$(kubectl get deployments | grep blockchain | wc -l | awk '{print $1}')
	sleep 1;
done

NUM_PENDING=$(kubectl get svc | grep blockchain | wc -l | awk '{print $1}')
while [ "${NUM_PENDING}" != "0" ]; do
	echo "Waiting for all blockchain servicess to be deleted. Remaining = ${NUM_PENDING}"
    NUM_PENDING=$(kubectl get svc | grep blockchain | wc -l | awk '{print $1}')
	sleep 1;
done

while [ "$(kubectl get pods | grep utils | wc -l | awk '{print $1}')" != "0" ]; do
	echo "Waiting for util pod to be deleted."
	sleep 1;
done

echo "All blockchain deployments & services have been removed"
