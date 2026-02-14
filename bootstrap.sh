#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/jared-paul/homelab.git"
BRANCH="main"

# Install K3s
echo "==> Installing K3s..."
curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

echo "==> Waiting for K3s to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=120s

# Install Argo CD
echo "==> Installing Argo CD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "==> Waiting for Argo CD to be ready..."
kubectl -n argocd wait --for=condition=available deployment/argocd-server --timeout=300s

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
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "==> Argo CD will now sync all apps from Git."
echo "==> Access the dashboard at https://argocd.cereal.box once DNS is configured."
