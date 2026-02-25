# Ralph Loop for `lab-infra`

This repo uses a **Ralph-style iterative loop**:

- Keep objective in `GOAL.md`
- Run small iterations
- Treat **files + git** as source of truth
- Pass a hard validation gate (`terraform init/validate/plan`) every iteration
- Commit frequently

## Run

```bash
cd lab-infra
MAX_ITERS=5 AUTO_COMMIT=1 ./scripts/ralph-loop.sh
```

## Why this helps

Long chats drift. Iterative, state-based runs converge better and recover faster.

## Current lab target

- 2 VMs: `gh-runner-01`, `podman-app-01`
- Minimal defaults:
  - 2 vCPU
  - 2048 MB RAM
  - 50 GB disk
- Provisioning strategy:
  - Manual Ubuntu 24.04 image/template
  - Ansible post-configuration
