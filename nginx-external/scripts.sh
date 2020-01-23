# get the aks creds
az aks get-credentials --resource-group aks-hybrid-networking-rg --name aks-basic-02

# Create a namespace for your ingress resources
kubectl create namespace ingress-basic

# add stable repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# install basic/external facing nginx
helm install external-nginx-ingress stable/nginx-ingress --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

# login to acr
az acr login --name <acr-name>

# use voting-app-redis as sample app
# tag image
docker tag azure-vote-front <acr-name>.azurecr.io/azure-vote-front:v1
# push image to acr
docker push <acr-name>.azurecr.io/azure-vote-front:v1