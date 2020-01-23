# Create a namespace for your ingress resources
kubectl create namespace ingress-basic

# Use Helm to deploy an NGINX ingress controller
helm install stable/nginx-ingress \
    --namespace ingress-basic \
    -f internal-ingress.yaml \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
    --generate-name

# verify ingress controller install succeeded
kubectl get service -l app=nginx-ingress --namespace ingress-basic

# add helm charts for azure samples
helm repo add azure-samples https://azure-samples.github.io/helm-charts/

# install helloworld app
helm install azure-samples/aks-helloworld --namespace ingress-basic --generate-name

# install a second helloworld app  instance
helm install azure-samples/aks-helloworld \
    --namespace ingress-basic \
    --set title="AKS Ingress Demo" \
    --set serviceName="ingress-demo" \
    --generate-name

# install a 3rd helloworld app  instance
helm install hello-world-the-third azure-samples/aks-helloworld \
    --namespace ingress-basic \
    --set title="Three three three" \
    --set serviceName="ingress-demo-third"

# apply helloworld ingress
kubectl apply -f helloworld-ingress.yaml

# create a pod to test with
kubectl run -it --rm aks-ingress-test --image=debian --namespace ingress-basic
# install curl
apt-get update && apt-get install -y curl

# run curl to access internal IP address (shows "Welcome to AKS...")
curl -L http://10.0.1.5

# test helloworld app (shows "AKS Ingress Demo")
curl -L http://10.0.1.5/hello-world-two


