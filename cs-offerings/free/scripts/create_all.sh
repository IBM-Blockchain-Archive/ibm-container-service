#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
	:
elif [ "${PWD##*/}" == "scripts" ]; then
	:
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

WITH_COUCHDB=false
PAID_STORAGE=false

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--with-couchdb)
				echo "Configured to setup network with couchdb"
				WITH_COUCHDB=true
				;;
			--paid-storage)
				echo "Configured to setup a paid storage on ibm-cs"
				PAID_STORAGE=true
		esac
		shift
	done
}

Parse_Arguments $@

echo ""
echo "=> CREATE_ALL: Creating storage"
if [ "$PAID_STORAGE" == "true" ]; then
	create/create_storage.sh --paid
else
	create/create_storage.sh 
fi

echo ""
echo "=> CREATE_ALL: Creating blockchain"
if [ "$WITH_COUCHDB" == "true" ]; then
	create/create_blockchain.sh --with-couchdb
else
	create/create_blockchain.sh
fi

echo ""
echo "=> CREATE_ALL: Running Create Channel"
PEER_MSPID="Org1MSP" CHANNEL_NAME="channel1" create/create_channel.sh

echo ""
echo "=> CREATE_ALL: Running Join Channel on Org1 Peer1"
CHANNEL_NAME="channel1" PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:5010" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" create/join_channel.sh

echo "=> CREATE_ALL: Running Join Channel on Org2 Peer1"
CHANNEL_NAME="channel1" PEER_MSPID="Org2MSP" PEER_ADDRESS="blockchain-org2peer1:5010" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" create/join_channel.sh

echo ""
echo "=> CREATE_ALL: Creating composer playground"
create/create_composer-playground.sh

# Can't create this until the user has performed manual actions in the Composer Playground.
# echo ""
# echo "=> CREATE_ALL: Creating composer rest server"
# create/create_composer-rest-server.sh

echo ""
echo "=> CREATE_ALL: Running Install Chaincode on Org1 Peer1"
CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"  PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:5010" create/chaincode_install.sh

echo ""
echo "=> CREATE_ALL: Running Install Chaincode on Org2 Peer1"
CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp"  PEER_MSPID="Org2MSP" PEER_ADDRESS="blockchain-org2peer1:5010" create/chaincode_install.sh

echo ""
echo "=> CREATE_ALL: Running instantiate chaincode on channel \"channel1\" using \"Org1MSP\""
CHANNEL_NAME="channel1" CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"  PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:5010" create/chaincode_instantiate.sh
