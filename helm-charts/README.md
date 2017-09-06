# IBM Blockchain Helm Charts

This directory contains [Helm Charts](https://github.com/kubernetes/helm/blob/master/docs/charts.md) for creating an IBM Blockchain Platform development sandbox.

## TL;DR;

### Kubernetes

Obtain a Kubernetes cluster using IBM Container Service by following the instructions [here](https://ibm-blockchain.github.io/setup/).

### Install Helm

1. Download and extract [Helm](https://github.com/kubernetes/helm#install) for your platform.
2. Install Helm by running the following commands:

   ```bash
   chmod +x helm
   mv helm /usr/local/bin
   helm init
   ```

### Deploy the Charts

Deploy all of the charts by running the following commands:

```bash
git clone https://github.com/IBM-Blockchain/ibm-container-service.git
cd ibm-container-service/helm-charts
./deploy_charts.sh
```

## Deploying the Charts Manually

Use the following instructions to deploy each chart manually.

 > **Note:** Give the charts time to install before moving on to the next chart.
 >
 >Use the command `kubectl get pods -a` to check on the status of the containers and ensure that none complete with an `Error` status.  
 >
 >Additional information can be obtained for a pod by using the command `kubectl logs <pod_name>`.

1. Deploy the blockchain network chart by running the following commands:

   ```bash
   cd ibm-container-service/helm-charts/ibm-blockchain-network
   helm install --name blockchain .
   ```

2. Deploy the blockchain channel chart by running the following commands:

   ```bash
   cd ibm-container-service/helm-charts/ibm-blockchain-channel
   helm install --name channel .
   ```

3. Deploy the blockchain chaincode chart by running the following commands:

   ```bash
   cd ibm-container-service/helm-charts/ibm-blockchain-chaincode
   helm install --name chaincode .
   ```

4. Deploy the Hyperledger Composer chart by running the following commands:

   ```bash
   cd ibm-container-service/helm-charts/ibm-blockchain-composer
   helm install --name composer .
   ```
