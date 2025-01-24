
# Flink Spot HPA Setup

This repository provides an automated setup for running Apache Flink on Kubernetes with Horizontal Pod Autoscaler (HPA) and AWS Spot Instances. The setup includes configuration for Flink's high availability, resource scaling using cluster autoscaler, and integration with Amazon S3 for state persistence.

## Directory Structure

```
punitkashyup-flink-spot-hpa/
├── README.md                            # Project documentation
├── Dockerfile                           # Dockerfile to build a Flink application image
├── cluster-autoscaler-autodiscover.yaml # YAML for setting up Kubernetes cluster autoscaler
├── delete.sh                            # Script to delete all deployed resources
├── flink-configuration-configmap.yaml   # ConfigMap for Flink configuration
├── install.sh                           # Script to install and configure Flink on Kubernetes
├── jobmanager-application-ha.yaml       # YAML for deploying Flink JobManager with HA
├── jobmanager-rest-service.yaml         # YAML for exposing the Flink REST API
├── jobmanager-service.yaml              # YAML for internal JobManager communication
├── managedNodeGroups.yml                # eksctl configuration for managed node groups
└── taskmanager-job-deployment.yaml      # YAML for deploying Flink TaskManagers
```

## Prerequisites

- Kubernetes Cluster (EKS recommended)
- `kubectl` CLI
- AWS CLI configured with required permissions
- `eksctl` installed for creating and managing EKS clusters
- Docker for building images

## Setup Guide

### 1. Create an EKS Cluster
Use the provided `managedNodeGroups.yml` file to create an EKS cluster with a combination of on-demand and spot instances.

```bash
eksctl create cluster -f managedNodeGroups.yml
```

### 2. Build and Push Docker Image
Build the Flink application Docker image using the provided `Dockerfile`.

```bash
docker build -t your-docker-repo/flink-app:1.0 .
docker push your-docker-repo/flink-app:1.0
```

### 3. Install Flink on Kubernetes
Run the `install.sh` script to deploy Flink on Kubernetes.

```bash
chmod +x install.sh
./install.sh
```

This script:
- Creates the necessary ConfigMaps for Flink configuration.
- Deploys the JobManager and TaskManager.
- Configures the Horizontal Pod Autoscaler for the TaskManager.
- Installs the Metrics Server for HPA functionality.

### 4. Cluster Autoscaler Configuration
Apply the `cluster-autoscaler-autodiscover.yaml` to enable Kubernetes cluster autoscaling.

```bash
kubectl apply -f cluster-autoscaler-autodiscover.yaml
```

Ensure the IAM role for the node group has permissions for autoscaling.

### 5. Access the Flink Dashboard
The JobManager REST API is exposed as a NodePort service. You can forward the port to your local machine:

```bash
kubectl port-forward service/flink-jobmanager-rest 8081:8081
```

Open the Flink dashboard at `http://localhost:8081`.

## Clean-Up

To delete all deployed resources, run the `delete.sh` script:

```bash
chmod +x delete.sh
./delete.sh
```

## Configuration Details

### Flink Configuration
Flink's configuration is defined in the `flink-configuration-configmap.yaml` file. Key configurations include:
- High availability using S3 (`high-availability.storageDir`)
- Reactive scheduler mode
- Default parallelism and memory configurations

### Node Groups
- **On-Demand Nodes**: For critical resources (`managed-ng-od`)
- **Spot Nodes**: For cost optimization (`managed-ng-spot`)

### Horizontal Pod Autoscaler (HPA)
The TaskManager is configured with HPA to scale pods based on CPU usage.

```bash
kubectl autoscale deployment flink-taskmanager --min=1 --max=10 --cpu-percent=45
```

## AWS S3 Integration
Flink uses Amazon S3 (`s3a://`) for state persistence. Update the `flink-configuration-configmap.yaml` with your AWS credentials and S3 bucket details.

## Troubleshooting

- **Metrics Server Not Found**: Ensure the Metrics Server is installed and running. Reapply it using:
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
  ```
- **Cluster Autoscaler Issues**: Check the logs for the Cluster Autoscaler pod:
  ```bash
  kubectl logs -n kube-system deployment/cluster-autoscaler
  ```

## License

This project is licensed under the MIT License. See the LICENSE file for details.
