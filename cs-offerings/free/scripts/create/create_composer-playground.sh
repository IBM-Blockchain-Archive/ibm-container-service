#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo "Creating composer-identity-import pod"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/composer-identity-import.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/composer-identity-import.yaml

while [ "$(kubectl get pod -a composer-identity-import | grep composer-identity-import | awk '{print $3}')" != "Completed" ]; do
    echo "Waiting for composer-identity-import container to be Completed"
    sleep 1;
done

if [ "$(kubectl get pod -a composer-identity-import | grep composer-identity-import | awk '{print $3}')" == "Completed" ]; then
	echo "Composer Identity Import Completed Successfully"
fi

if [ "$(kubectl get pod -a composer-identity-import | grep composer-identity-import | awk '{print $3}')" != "Completed" ]; then
	echo "Composer Identity Import Failed"
fi

echo "Deleting composer-identity-import pod"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/composer-identity-import.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/composer-identity-import.yaml

while [ "$(kubectl get svc | grep composer-identity-import | wc -l | awk '{print $1}')" != "0" ]; do
	echo "Waiting for composer-identity-import pod to be deleted"
	sleep 1;
done

echo "Creating composer-playground deployment"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/composer-playground.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/composer-playground.yaml

if [ "$(kubectl get svc | grep composer-playground | wc -l | awk '{print $1}')" == "0" ]; then
    echo "Creating composer-playground service"
    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/composer-playground-services.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/composer-playground-services.yaml
fi

echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments | grep composer-playground | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments | grep composer-playground | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
done

echo "Composer playground created successfully"
