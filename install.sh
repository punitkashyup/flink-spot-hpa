kubectl create -f flink-configuration-configmap.yaml
kubectl create -f jobmanager-application-ha.yaml
kubectl create -f jobmanager-service.yaml
kubectl create -f jobmanager-rest-service.yaml
kubectl create -f taskmanager-job-deployment.yaml
kubectl autoscale deployment flink-taskmanager --min=1 --max=10 --cpu-percent=45
sleep 30
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
kubectl port-forward service/flink-jobmanager-rest  8081