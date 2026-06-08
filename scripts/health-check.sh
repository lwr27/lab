#!/bin/bash

echo "=== Starting health check ==="
NAMESPACE=${1:-default}
APP="myapp"
TIMEOUT=60
ELAPSED=0

# Set expected replicas based on namespace
if [ "$NAMESPACE" = "production" ]; then
  EXPECTED=2
else
  EXPECTED=1
fi

echo "Checking AKS connectivity..."
if kubectl cluster-info > /dev/null 2>&1; then
  echo "AKS cluster is reachable"
else
  echo "ERROR: Cannot reach AKS cluster"
  exit 1
fi

echo "Checking pod health in namespace: $NAMESPACE (expecting $EXPECTED pods)..."

while [ $ELAPSED -lt $TIMEOUT ]
do
  RUNNING=$(kubectl get pods -n $NAMESPACE -l app=$APP --field-selector=status.phase=Running --no-headers | wc -l)
  
  if [ $RUNNING -ge $EXPECTED ]
  then
    echo "SUCCESS: $RUNNING pod(s) running for $APP in $NAMESPACE"
    exit 0
  fi
  
  echo "Waiting for pods... ($RUNNING/$EXPECTED running, ${ELAPSED}s elapsed)"
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

echo "ERROR: Pods did not come up within ${TIMEOUT} seconds"
exit 1
