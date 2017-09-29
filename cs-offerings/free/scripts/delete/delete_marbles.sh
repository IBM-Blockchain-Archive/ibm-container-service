#!/bin/bash
if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

WITH_COUCHDB=false
PAID=false

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--with-couchdb)
				echo "Configured to setup network with couchdb"
				WITH_COUCHDB=true
				;;
			--paid)
				echo "Configured to setup a paid storage on ibm-cs"
				PAID=true
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

echo "Deleting marbles service"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/marbles-services-${OFFERING}.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/marbles-services-${OFFERING}.yaml

sleep 15

echo "Deleting marbles pod"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/marbles.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/marbles.yaml
