#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

if [ "$(kubectl get pvc | grep shared-pvc | awk '{print $3}')" != "shared-pv" ]; then
    echo "The Persistant Volume does not seem to exist or is not bound"
	echo "Creating Persistant Volume"
	
	# making a pv on kubernetes
	echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/storage.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/storage.yaml
	sleep 5
	if [ "kubectl get pvc | grep shared-pvc | awk '{print $3}'" != "shared-pv" ]; then
		echo "Success creating PV"
	else
		echo "Failed to create PV"
	fi
else
	echo "The Persistant Volume exists, not creating again"
fi


