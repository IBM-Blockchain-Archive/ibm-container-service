#!/bin/bash

#admin cert:
#	private:
#	/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/key.pem 

#	public:
#	/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem 

ORG=""
CLUSTER_NAME=""

Usage() {
	echo ""
	echo "Usage: ./generate-connection-profile.sh -o <org1|org2> -c <cluster-name>"
	echo ""
	echo "Options:"
	echo "	-o or -organization: 	org1 or org2 based on what organization you want the connection profile for."
	echo "	-c or -cluster:		the ibm-container service cluster name."
	echo ""
	echo "Example: ./generate-connection-profile.sh -o org1 -c blockchain"
	echo ""
	exit 1
}

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--organization | -o)
				shift
				ORG="$1"
				;;
			--cluster-name | -c)
				shift
				CLUSTER_NAME=$1
				;;
		esac
		shift
	done
}
Parse_Arguments $@

if [ "$ORG" == "" ] || [ "$CLUSTER_NAME" == "" ];then
	Usage
fi

if [ "${ORG}" == "org1" ]; then
	MSP="Org1MSP"
	PEER="org1peer1"
elif [ "${ORG}" == "org2" ]; then
	MSP="Org2MSP"
	PEER="org2peer1"
else
	Usage
fi

PUBLIC_ADDRESS=$(bx cs workers ${CLUSTER_NAME} | tail -1 | awk '{print $2}')
echo "Public address for cluster is: ${PUBLIC_ADDRESS}"
PEER_CONTAINER_NAME=$(kubectl get pods -a | grep ${PEER} | awk '{print $1}')
echo "Container for org1peer1 is ${PEER_CONTAINER_NAME}"
ADMIN_PRIVATE_KEY=$(kubectl exec ${PEER_CONTAINER_NAME} cat /shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/key.pem)
ADMIN_PUBLIC_KEY=$(kubectl exec ${PEER_CONTAINER_NAME} cat /shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem )

# echo "admin private key is ${ADMIN_PRIVATE_KEY}"
# echo "admin public key is ${ADMIN_PUBLIC_KEY}"

ADMIN_PRIVATE_KEY_ONELINE=$(echo "${ADMIN_PRIVATE_KEY//$'\n'/\\\r\\\n}\\\r\\\n")
ADMIN_PUBLIC_KEY_ONELINE=$(echo "${ADMIN_PUBLIC_KEY//$'\n'/\\\r\\\n}\\\r\\\n")

# echo "admin private key one line is ${ADMIN_PRIVATE_KEY_ONELINE}"
# echo "admin public key one line is ${ADMIN_PUBLIC_KEY_ONELINE}"

if [ "${ORG}" == "org1" ];then
	echo "Setting the json for org1"
	cp connection-profile-org1.json.tmpl connection-profile-org1.json

	OLD_STRING="ADMINPRIVATEKEY"
	sed -i "" "s|${OLD_STRING}|${ADMIN_PRIVATE_KEY_ONELINE}|g" connection-profile-org1.json
	
	OLD_STRING="ADMINPUBLICKEY"
	sed -i "" "s|${OLD_STRING}|${ADMIN_PUBLIC_KEY_ONELINE}|g" connection-profile-org1.json
	
	OLD_STRING="PUBLICIP"
	sed -i "" "s|${OLD_STRING}|${PUBLIC_ADDRESS}|g" connection-profile-org1.json

	echo "Check the profile: connection-profile-org1.json"
fi