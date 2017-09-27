#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo "Deleting Persistant Storage"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/storage.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/storage.yaml
