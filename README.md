# Homelab

GitOps-managed homelab running on Proxmox + K3s.

## Stack

- **Proxmox** — VM hypervisor
- **K3s** — Lightweight Kubernetes
- **Argo CD** — GitOps continuous deployment
- **Kargo** — Multi-stage promotion engine
- **Helm** — Kubernetes package manager
- **OpenTofu** — Infrastructure provisioning
- **Ansible** — Configuration management

## Bootstrap

Provision infrastructure and bootstrap the cluster:

```bash
cd infra/ansible
ansible-playbook -i inventory.yaml home.yaml
```

This installs K3s, Helm, and Argo CD, then creates the root application that points at this repo. After bootstrap, Argo CD manages everything — including itself.

## Structure

```
homelab/
├── home/                         # Platform services (managed by ArgoCD)
│   ├── argocd/
│   │   ├── app-of-apps/          # Root app-of-apps (plain YAML manifests)
│   │   │   ├── main.yaml         # Root Application
│   │   │   ├── argocd.yaml
│   │   │   ├── kargo.yaml
│   │   │   ├── pihole.yaml
│   │   │   ├── cert-manager.yaml
│   │   │   ├── homepage.yaml
│   │   │   └── hello.yaml
│   │   ├── install/              # Helm values for bootstrap
│   │   └── clusters/             # Cluster registration secrets
│   ├── homepage/                 # Homepage dashboard (Helm chart)
│   ├── kargo/
│   ├── pihole/
│   └── cert-manager/
├── apps/                         # User-facing applications
│   └── hello/
│       ├── chart/                # Helm chart
│       ├── values/               # Per-stage values (staging, production)
│       ├── argocd/               # ArgoCD Application manifests
│       └── kargo/                # Kargo promotion resources
└── infra/                        # Infrastructure provisioning
    ├── opentofu/                 # Proxmox VM definitions
    └── ansible/                  # Node bootstrapping playbooks
```

## Access

| Service    | URL                              |
|------------|----------------------------------|
| Argo CD    | https://argocd.cereal.box        |
| Kargo      | https://kargo.cereal.box         |
| Pi-hole    | https://pihole.cereal.box        |
| Homepage   | https://homepage.cereal.box      |
| Hello      | https://hello.cereal.box         |
| Hello (staging) | https://hello-staging.cereal.box |

## DNS

All `*.cereal.box` domains resolve to `192.168.0.19` (K3s node IP), managed by Pi-hole custom DNS entries.
