#!/bin/bash
if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

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

echo "Creating marbles service"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/marbles-services-${OFFERING}.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/marbles-services-${OFFERING}.yaml

sleep 15

echo "Creating marbles pod"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/marbles.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/marbles.yaml

echo "Waiting for marbles to be up....."
sleep 30

PUBLIC_IP=$(bx cs workers blockchain | awk 'FNR==3{print $2}')
echo "Please go to Marbles UI: http://${PUBLIC_IP}:32001 for next steps"
