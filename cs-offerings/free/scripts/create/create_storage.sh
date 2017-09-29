#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo "Creating Persistent Volumes"
if [ "${1}" == "--paid" ]; then
	if [ "$(kubectl get pvc | grep shared-pvc | wc -l | awk '{ print $1 }')" == "0" ]; then
		echo "The paid PVC does not seem to exist"
		echo "Creating PVC named shared-pvc"

		# making a PVC on ibm-cs paid version
		echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/storage-paid.yaml"
		kubectl create -f ${KUBECONFIG_FOLDER}/storage-paid.yaml
		sleep 5

		while [ "$(kubectl get pvc | grep shared-pvc | wc -l | awk '{ print $1 }')" == "0" ];
		do
			echo "Waiting for storage to be created"
			sleep 5
		done
	else
		echo "The PVC with name shared-pvc exists, not creating again"
		#echo "Note: This can be a normal storage and not a ibm-cs storage, please check for more details"
	fi
else
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

fi

