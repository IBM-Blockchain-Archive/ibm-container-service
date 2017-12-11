#!/bin/bash

#
# deploy_charts.sh: Deploys the Helm Charts required to create an IBM Blockchain Platform
#                   development sandbox using IBM Container Service.
#
# Contributors:     Eddie Allen
#                   Mihir Shah
#                   Dhyey Shah
#
# Version:          5 September 2017
#

#
# checkDependencies: Checks to ensure required tools are installed.
#
function checkDependencies() {
    type kubectl >/dev/null 2>&1 || { echo >&2 "I require kubectl but it is not installed.  Aborting."; exit 1; }
    type helm >/dev/null 2>&1 || { echo >&2 "I require helm but it is not installed.  Aborting."; exit 1; }
}

#
# cleanEnvironment: Cleans the services, volumes, and pods from the Kubernetes cluster.
#
function cleanEnvironment() {
    HELM_RELEASES=$(helm list | tail -n +2 | awk '{ print $1 }')

    # Delete any existing releases
    if [[ ! -z ${HELM_RELEASES// /} ]]; then
        echo -n "Deleting the following helm releases: "
        echo ${HELM_RELEASES}...
        helm delete --purge ${HELM_RELEASES}
    fi

    # Wipe the /shared persistent volume if it exists (it should be removed with chart removal)
    kubectl get pv shared > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        kubectl create -f ../cs-offerings/kube-configs/wipe_shared.yaml

        # Wait for the wipe shared pod to finish
        while [ "$(kubectl get pod -a wipeshared | grep wipeshared | awk '{print $3}')" != "Completed" ]; do
            echo "Waiting for the shared folder to be erased..."
            sleep 1;
        done

        # Delete the wipe shared pod
        kubectl delete -f ../cs-offerings/kube-configs/wipe_shared.yaml
    fi
}

#
# getPods: Updates the pod status variables.
#
function getPodStatus() {
    PODS=$(kubectl get pods -a)
    PODS_RUNNING=$(echo "${PODS}" | grep Running | wc -l)
    PODS_COMPLETED=$(echo "${PODS}" | grep Completed | wc -l)
    PODS_ERROR=$(echo "${PODS}" | grep Error | wc -l)
}

#
# checkPodStatus: Checks the status of all pods ensure the correct number are running,
#                 completed, and that none completed with errors.
#
# Parameters:     $1 - The expected number of pods in the 'Running' state.
#                 $2 - The expected number of pods in the 'Completed' state.
#
function checkPodStatus() {
    # Ensure arguments were passed
    if [[ ${#} -ne 2 ]]; then
        echo "Usage: ${FUNCNAME} <num_running_pods> <num_completed_pods>"
        return -1
    fi

    NUM_RUNNING=${1}
    NUM_COMPLETED=${2}

    # Get the status of the pods
    getPodStatus

    # Wait for the pods to initialize
    while [ "${PODS_RUNNING}" -ne ${NUM_RUNNING} ] || [ "${PODS_COMPLETED}" -ne ${NUM_COMPLETED} ]; do
        if [ "${PODS_ERROR}" -gt 0 ]; then
            echo "$(basename $0): error: the following pods failed with errors:"
            echo "$(echo "$PODS" | grep Error)"
            exit -1
        fi

        echo "Waiting for the pods to initialize..."
        sleep 1

        getPodStatus
    done
}

#
# startNetwork: Starts the CA, orderer, and peer containers.
#
function startNetwork() {
    RELEASE_NAME="blockchain"
    TOTAL_RUNNING=4
    TOTAL_COMPLETED=1

    # Move into the directory
    pushd ibm-blockchain-network >/dev/null 2>&1

    # Install the chart
    helm install --name ${RELEASE_NAME} .


    # Ensure the correct number of pods are running and completed
    checkPodStatus ${TOTAL_RUNNING} ${TOTAL_COMPLETED}

    popd >/dev/null 2>&1
}

#
# startChannel: Starts the create and join channel containers.
#
function startChannel() {
    RELEASE_NAME="channel"
    TOTAL_RUNNING=4
    TOTAL_COMPLETED=4

    # Move into the directory
    pushd ibm-blockchain-channel >/dev/null 2>&1

    # Install the chart
    helm install --name ${RELEASE_NAME} .


    # Ensure the correct number of pods are running and completed
    checkPodStatus ${TOTAL_RUNNING} ${TOTAL_COMPLETED}

    popd >/dev/null 2>&1
}

#
# startChaincode: Starts the install and instantiate chaincode containers.
#
function startChaincode() {
    RELEASE_NAME="chaincode"
    TOTAL_RUNNING=4
    TOTAL_COMPLETED=7

    # Move into the directory
    pushd ibm-blockchain-chaincode >/dev/null 2>&1

    # Install the chart
    helm install --name ${RELEASE_NAME} .

    # Ensure the correct number of pods are running and completed
    checkPodStatus ${TOTAL_RUNNING} ${TOTAL_COMPLETED}

    popd >/dev/null 2>&1
}

#
# startComposer: Starts the Hyperledger Composer containers.
#
function startComposer() {
    RELEASE_NAME="composer"
    TOTAL_RUNNING=6
    TOTAL_COMPLETED=8

    # Move into the directory
    pushd ibm-blockchain-composer >/dev/null 2>&1

    # Install the chart
    helm install --name ${RELEASE_NAME} .

    # Ensure the correct number of pods are running and completed
    checkPodStatus ${TOTAL_RUNNING} ${TOTAL_COMPLETED}

    popd >/dev/null 2>&1
}

#
# Clean up and deploy the charts
#
checkDependencies
cleanEnvironment
startNetwork
startChannel
startChaincode
startComposer
