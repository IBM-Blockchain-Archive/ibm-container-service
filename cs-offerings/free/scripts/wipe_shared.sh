#!/bin/bash

# cp ../kube-configs/wipe_shared.yaml.base ../kube-configs/wipe_shared.yaml

kubectl create -f ../kube-configs/wipe_shared.yaml

while [ "$(kubectl get pod -a wipeshared | grep wipeshared | awk '{print $3}')" != "Completed" ]; do
    echo "Waiting for the shared folder to be erased"
    sleep 1;
done

kubectl delete -f ../kube-configs/wipe_shared.yaml
