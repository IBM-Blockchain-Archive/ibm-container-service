#!/bin/bash
if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

PUBLIC_IP=$(bx cs workers blockchain | awk 'FNR==3{print $2}')

echo "Deleting marbles service"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/marbles-services.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/marbles-services.yaml

sleep 15

echo "Deleting marbles pod"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/marbles.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/marbles.yaml
