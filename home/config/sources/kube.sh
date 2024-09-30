#!/usr/bin/env zsh

if command -v hx &> /dev/null; then
  export KUBE_EDITOR=hx
else
  echo "hx is not installed. Using default KUBE_EDITOR=$KUBE_EDITOR"
fi

# Check if Docker is running
if docker info > /dev/null 2>&1; then
  # echo "Docker is running..."

  # Check if ArgoCD is installed by verifying the existence of the argocd namespace
  if kubectl get namespace argocd > /dev/null 2>&1; then
    # echo "ArgoCD is installed on the cluster."

    # Check if the initial admin secret exists
    if kubectl -n argocd get secret argocd-initial-admin-secret > /dev/null 2>&1; then
      # echo "Found ArgoCD initial admin secret."

      # Export ArgoCD-related environment variables
      export ARGOCD_CONTEXT=kind-kind
      export ARGOCD_USERNAME=admin
      export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo)
      export ARGOCD_SERVER="argo-127-0-0-1.nip.io"
      alias argoin="argocd login $ARGOCD_SERVER --username $ARGOCD_USERNAME --password $ARGOCD_PASSWORD --grpc-web"
      
    # else
    #   echo "Error: ArgoCD initial admin secret not found in the argocd namespace."
    fi

  # else
  #   echo "ArgoCD is not installed on the cluster."
  fi

else
  echo "Docker is not running."
fi

