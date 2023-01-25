#!/bin/bash

# Pré-requisitos:
#       Utilizar um usuário sudo
#	Instalação do Docker: https://docs.docker.com/engine/install/centos/
#	Manage Docker as a non-root user: https://docs.docker.com/engine/install/linux-postinstall/

# Instalando minikube v1.20.0 on Centos 7.9.2009 , Kubernetes v1.20.2
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Iniciando e habilitando ingress
minikube start --memory=10g
minikube addons enable ingress

# Instalando Helm v3 - https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f ./get_helm.sh

# "Instalando" o kubectl (a preguiça falou mais alto :P)
alias kubectl="minikube kubectl --"

# Criando o namespace
kubectl apply -f kube-yaml/ns.yaml

# Criando configmap
kubectl apply -f kube-yaml/simpleapp-cm.yaml

# Criando deployment
kubectl apply -f kube-yaml/simpleapp.yaml

# Criando service
kubectl apply -f kube-yaml/simpleapp-svc.yaml

# Criando ingress
sleep 40
kubectl apply -f kube-yaml/challenge-ingress.yaml

# Adicionando hosts em /etc/hosts
echo -e "$(minikube ip)\tapp.prova" | sudo tee -a /etc/hosts
echo -e "$(minikube ip)\tkibana.prova" | sudo tee -a /etc/hosts

# Adicionando helm repo elastic
helm repo add elastic https://helm.elastic.co

# Visualizando recursos
sleep 90
#kubectl get pod,service,deployment,ingress,daemonset -A | grep -vP '^(default|kube)'
watch -n 1 minikube kubectl -- get pod,service,deployment,ingress,daemonset -n prova
