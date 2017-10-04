#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

PAID=false

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--paid)
				echo "Configured to setup a paid storage on ibm-cs"
				PAID=true
				;;
			--business-network-id)
				shift
				COMPOSER_BUSINESS_NETWORK=$1
				;;	
		esac
		shift
	done
}

Parse_Arguments $@

if [ "${PAID}" == "true" ]; then
	OFFERING="paid"
else
	OFFERING="free"
fi

if [ -z ${COMPOSER_BUSINESS_NETWORK} ]; then
	echo "Usage: $0 --business-network-id <business-network-name> [--paid]"
    exit 1
fi

echo "Preparing yaml file for create composer-rest-server"
sed -e "s/%COMPOSER_BUSINESS_NETWORK%/${COMPOSER_BUSINESS_NETWORK}/g" ${KUBECONFIG_FOLDER}/composer-rest-server.yaml.base > ${KUBECONFIG_FOLDER}/composer-rest-server.yaml

echo "Creating composer-rest-server pod"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/composer-rest-server.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/composer-rest-server.yaml

if [ "$(kubectl get svc | grep composer-rest-server | wc -l | awk '{print $1}')" == "0" ]; then
    echo "Creating composer-rest-server service"
    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/composer-rest-server-services-${OFFERING}.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/composer-rest-server-services-${OFFERING}.yaml
fi

echo "Composer rest server created successfully"
