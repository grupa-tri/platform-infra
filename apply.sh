#!/usr/bin/env bash
set -euo pipefail

# --- configuration ---
readonly PROJECT_ID="turing-cell-497816-p0"
readonly REGION="europe-west3"
readonly BUCKET_NAME="${PROJECT_ID}-terraform-state"
readonly SERVICE_ACCOUNT_ID="terraform"
readonly VAR_FILE="terraform.tfvars"
# -----------------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BUCKET_URI="gs://${BUCKET_NAME}"
readonly SA_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
readonly SA_MEMBER="serviceAccount:${SA_EMAIL}"
readonly TERRAFORM_PROJECT_ROLES=(
  "roles/editor"
  "roles/iam.serviceAccountAdmin"
  "roles/resourcemanager.projectIamAdmin"
  "roles/container.admin"
)

log() {
  echo "==> $*"
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is not installed or not in PATH"
}

member_for_principal() {
  local principal="$1"

  if [[ "$principal" == *@*.iam.gserviceaccount.com ]]; then
    echo "serviceAccount:${principal}"
  else
    echo "user:${principal}"
  fi
}

add_iam_binding() {
  local description="$1"
  shift

  set +e
  local output
  output="$("$@" 2>&1)"
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]] || grep -qi "already exists" <<<"$output"; then
    log "${description}"
    return 0
  fi

  echo "$output" >&2
  die "failed: ${description}"
}

require_command gcloud
require_command terraform

[[ -f "${SCRIPT_DIR}/${VAR_FILE}" ]] || die "${VAR_FILE} not found in ${SCRIPT_DIR}"

BOOTSTRAP_PRINCIPAL="$(gcloud auth list --filter=status:ACTIVE --format='value(account)' | head -n 1)"
[[ -n "$BOOTSTRAP_PRINCIPAL" ]] || die "no active gcloud account found; run: gcloud auth login"
BOOTSTRAP_MEMBER="$(member_for_principal "$BOOTSTRAP_PRINCIPAL")"

if [[ -f "${SCRIPT_DIR}/terraform.tfstate" ]]; then
  log "local terraform.tfstate found — if migrating to remote state, run:"
  log "  GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=${SA_EMAIL} terraform init -migrate-state"
fi

log "using project: ${PROJECT_ID}"
log "using region: ${REGION}"
log "state bucket: ${BUCKET_URI}"
log "terraform service account: ${SA_EMAIL}"
log "bootstrap principal: ${BOOTSTRAP_MEMBER}"

log "setting gcloud project"
gcloud config set project "$PROJECT_ID" >/dev/null

log "enabling storage.googleapis.com"
gcloud services enable storage.googleapis.com --project="$PROJECT_ID"
gcloud services enable iam.googleapis.com --project="$PROJECT_ID"

if gcloud iam service-accounts describe "$SA_EMAIL" --project="$PROJECT_ID" >/dev/null 2>&1; then
  log "service account already exists: ${SA_EMAIL}"
else
  log "creating service account: ${SA_EMAIL}"
  gcloud iam service-accounts create "$SERVICE_ACCOUNT_ID" \
    --project="$PROJECT_ID" \
    --display-name="Terraform"
fi

if gcloud storage buckets describe "$BUCKET_URI" --project="$PROJECT_ID" >/dev/null 2>&1; then
  log "bucket already exists: ${BUCKET_URI}"
else
  log "creating bucket: ${BUCKET_URI}"
  gcloud storage buckets create "$BUCKET_URI" \
    --project="$PROJECT_ID" \
    --location="$REGION" \
    --uniform-bucket-level-access
fi

log "enabling bucket versioning"
gcloud storage buckets update "$BUCKET_URI" --versioning

log "enabling public access prevention"
gcloud storage buckets update "$BUCKET_URI" --public-access-prevention

add_iam_binding "granting roles/storage.objectAdmin on ${BUCKET_URI} to ${SA_MEMBER}" \
  gcloud storage buckets add-iam-policy-binding "$BUCKET_URI" \
  --member="$SA_MEMBER" \
  --role="roles/storage.objectAdmin"

for role in "${TERRAFORM_PROJECT_ROLES[@]}"; do
  add_iam_binding "granting ${role} on project ${PROJECT_ID} to ${SA_MEMBER}" \
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="$SA_MEMBER" \
    --role="$role"
done

add_iam_binding "granting roles/iam.serviceAccountTokenCreator on ${SA_EMAIL} to ${BOOTSTRAP_MEMBER}" \
  gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
  --project="$PROJECT_ID" \
  --member="$BOOTSTRAP_MEMBER" \
  --role="roles/iam.serviceAccountTokenCreator"

cd "$SCRIPT_DIR"

export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="$SA_EMAIL"

log "initializing terraform (as ${SA_EMAIL})"
terraform init

log "applying terraform (as ${SA_EMAIL})"
terraform apply -auto-approve -var-file="$VAR_FILE"

log "done"
