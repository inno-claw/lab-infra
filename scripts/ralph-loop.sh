#!/usr/bin/env bash
set -euo pipefail

# Ralph-style orchestration loop for lab-infra.
# Principle: every iteration reads current repo state + goal file, applies one small step,
# validates, then commits.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GOAL_FILE="${GOAL_FILE:-$REPO_ROOT/GOAL.md}"
MAX_ITERS="${MAX_ITERS:-5}"
AUTO_COMMIT="${AUTO_COMMIT:-1}"

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1"; exit 1; }
}

require_cmd git
require_cmd terraform

if [[ ! -f "$GOAL_FILE" ]]; then
  cat > "$GOAL_FILE" << 'GEOF'
# GOAL
Build and evolve the local-only vSphere training lab infra.

## Done criteria
- terraform init/validate/plan succeed locally
- VM defaults remain minimal (2 vCPU, 2GB RAM, 50GB disk)
- docs reflect current architecture and runbook
GEOF
  log "Created default GOAL.md"
fi

run_checks() {
  (cd "$REPO_ROOT/terraform" && terraform init -input=false >/dev/null && terraform validate >/dev/null && terraform plan -input=false -no-color >/dev/null)
}

commit_if_needed() {
  if [[ "$AUTO_COMMIT" != "1" ]]; then
    return
  fi
  if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
    git -C "$REPO_ROOT" add -A
    if ! git -C "$REPO_ROOT" diff --cached --quiet; then
      git -C "$REPO_ROOT" commit -m "chore(ralph-loop): iterative update" >/dev/null || true
      log "Committed iteration changes"
    fi
  fi
}

log "Starting Ralph Loop (iterations=$MAX_ITERS)"
for i in $(seq 1 "$MAX_ITERS"); do
  log "Iteration $i/$MAX_ITERS"

  # Snapshot state
  git -C "$REPO_ROOT" status --short > "$REPO_ROOT/.ralph-status.txt" || true

  # Placeholder action: keep docs + goal in sync with current terraform defaults
  cpu=$(awk -F'= ' '/variable "vm_cpu"/{f=1} f && /default =/{gsub(/ /,""); print $3; exit}' "$REPO_ROOT/terraform/variables.tf" || echo "2")
  mem=$(awk -F'= ' '/variable "vm_memory_mb"/{f=1} f && /default =/{gsub(/ /,""); print $3; exit}' "$REPO_ROOT/terraform/variables.tf" || echo "2048")
  disk=$(awk -F'= ' '/variable "vm_disk_gb"/{f=1} f && /default =/{gsub(/ /,""); print $3; exit}' "$REPO_ROOT/terraform/variables.tf" || echo "50")

  sed -i '' "s/^- vm_cpu: .*/- vm_cpu: ${cpu}/" "$GOAL_FILE" 2>/dev/null || true
  sed -i '' "s/^- vm_memory_mb: .*/- vm_memory_mb: ${mem}/" "$GOAL_FILE" 2>/dev/null || true
  sed -i '' "s/^- vm_disk_gb: .*/- vm_disk_gb: ${disk}/" "$GOAL_FILE" 2>/dev/null || true

  if ! grep -q '^- vm_cpu:' "$GOAL_FILE"; then
    cat >> "$GOAL_FILE" << EOF2

## Current defaults
- vm_cpu: ${cpu}
- vm_memory_mb: ${mem}
- vm_disk_gb: ${disk}
EOF2
  fi

  # Validate gate
  if run_checks; then
    log "Validation gate passed"
    commit_if_needed
  else
    log "Validation failed; stop loop"
    exit 1
  fi

done

log "Ralph Loop complete"
