#!/bin/bash

# Check if the namespace name is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

NAMESPACE=$1

# Step 1: Forcefully delete all resources within the namespace
echo "Forcefully deleting all resources in the namespace: $NAMESPACE"
kubectl delete all --all -n $NAMESPACE --grace-period=0 --force

# Step 2: Forcefully delete any remaining resources (configmaps, secrets, etc.)
echo "Forcefully deleting all non-pod resources in the namespace: $NAMESPACE"
kubectl delete configmap,secret,pvc --all -n $NAMESPACE --grace-period=0 --force

# Step 3: Patch the namespace to remove the finalizer
echo "Patching namespace to remove finalizers: $NAMESPACE"
kubectl patch namespace $NAMESPACE \
  -p '{"metadata":{"finalizers":null}}' \
  --type=merge

# Step 4: Forcefully delete the namespace
echo "Forcefully deleting namespace: $NAMESPACE"
kubectl delete namespace $NAMESPACE --grace-period=0 --force

echo "Namespace $NAMESPACE and its resources have been forcefully deleted."

