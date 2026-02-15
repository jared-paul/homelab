#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/jared-paul/homelab.git"
BRANCH="main"

# Install K3s
echo "==> Installing K3s..."
curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> Waiting for K3s to be ready..."
sleep 10
kubectl wait --for=condition=Ready node --all --timeout=120s

# Install Helm
echo "==> Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Argo CD via Helm (matches the argo-cd chart used by the argocd app)
echo "==> Installing Argo CD via Helm..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd --namespace argocd --version 9.4.2 \
  --set configs.params."server\.insecure"=true \
  --wait --timeout 300s

# Point Argo CD at the homelab repo
echo "==> Creating root application..."
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${BRANCH}
    path: apps
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
EOF

echo ""
echo "==> Bootstrap complete!"
echo "==> Argo CD admin password:"
kubectl -n argocd get secret argocd-secret -o jsonpath="{.data.clearPassword}" | base64 -d 2>/dev/null \
  || kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null \
  || echo "(password not found — set one manually)"
echo ""
echo ""
echo "==> Argo CD will now sync all apps from Git."
echo "==> Access the dashboard at https://argocd.cereal.box once DNS is configured."
