# Homelab

GitOps-managed homelab running on Proxmox + K3s.

## Stack

- **Proxmox** — VM hypervisor
- **K3s** — Lightweight Kubernetes
- **Argo CD** — GitOps continuous deployment
- **Kargo** — Multi-stage promotion (coming soon)
- **Helm** — Kubernetes package manager

## Bootstrap

On a fresh K3s cluster:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

This installs Argo CD and creates the root application that points at this repo.
After bootstrap, Argo CD manages everything — including itself.

## Structure

```
homelab/
├── bootstrap.sh          # One-time cluster bootstrap
└── apps/                 # App-of-apps root
    ├── Chart.yaml
    ├── values.yaml
    ├── templates/        # Argo CD Application definitions
    │   └── argocd.yaml
    └── argocd/           # Argo CD self-management
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── configmap.yaml
            └── ingress.yaml
```

## Access

| Service | URL |
|---------|-----|
| Argo CD | https://argocd.cereal.box |

## DNS

Point `argocd.cereal.box` to `192.168.0.19` (K3s node IP).
