# Lab Infra (vSphere + Ansible)

Local-only training lab scaffold for Ubuntu 24.04 host.

## Target topology
- 2 VMs total
  - `gh-runner-01` (GitHub self-hosted runner)
  - `podman-app-01` (Podman deployments)

## Planned default VM sizing
- 2 vCPU
- 2 GB RAM
- 50 GB disk

## Quick start
```bash
terraform init
terraform validate
terraform plan
```

> Note: By default `deploy_enabled=false`, so planning works without live vSphere access.


## Provisioning approach
- **Image flow:** Manual Ubuntu 24.04 image/template
- **Post config:** Ansible playbooks after VM provisioning


## Ralph Loop
Use `scripts/ralph-loop.sh` to run iterative, small-step automation driven by filesystem + git state.
See `docs/RALPH_LOOP.md` for details.
