#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="${ROOT_DIR}/tests/e2e"
CLUSTER_CREATED=false
CLUSTER_NAME="${CLUSTER_NAME:-$(mktemp -u "nuc-knative-e2e-XXXXXXXXXX" | tr "[:upper:]" "[:lower:]")}"
# kindest/node images are published on kind's cadence, not for every Kubernetes patch release.
K8S_VERSION="${K8S_VERSION:-v1.35.0}"
E2E_NAMESPACE="nuc-knative-e2e"
RELEASE_NAME="nuc-knative-e2e"
VALUES_FILE="tests/e2e/values/install.values.yaml"
CRD_FILE="tests/e2e/crds.yaml"

RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

log_error() { echo -e "${RED}Error:${RESET} $1" >&2; }
log_info() { echo -e "$1"; }
log_warn() { echo -e "${YELLOW}Warning:${RESET} $1" >&2; }

show_help() {
  echo "Usage: $(basename "$0") [helm upgrade/install options]"
  echo ""
  echo "Create a kind cluster, install local Knative-style CRD fixtures, and run Helm install/upgrade against the root chart."
  echo "Unknown arguments are passed through to 'helm upgrade --install'."
  echo ""
  echo "Environment overrides:"
  echo "  CLUSTER_NAME          Kind cluster name"
  echo "  K8S_VERSION           kindest/node tag"
  echo ""
}

verify_prerequisites() {
  for bin in docker kind kubectl helm; do
    if ! command -v "${bin}" >/dev/null 2>&1; then
      log_error "${bin} is not installed"
      exit 1
    fi
  done
}

cleanup() {
  local exit_code=$?

  if [ "${exit_code}" -ne 0 ] && [ "${CLUSTER_CREATED}" = true ]; then
    dump_cluster_state || true
  fi

  log_info "Cleaning up resources"

  if [ "${CLUSTER_CREATED}" = true ]; then
    log_info "Removing kind cluster ${CLUSTER_NAME}"
    if kind get clusters | grep -q "${CLUSTER_NAME}"; then
      kind delete cluster --name="${CLUSTER_NAME}"
    else
      log_warn "kind cluster ${CLUSTER_NAME} not found"
    fi
  fi

  exit "${exit_code}"
}

dump_cluster_state() {
  log_warn "Dumping Knative resources from ${CLUSTER_NAME}"
  kubectl get clusterdomainclaims.networking.internal.knative.dev || true
  kubectl get \
    certificates.networking.internal.knative.dev,configurations.serving.knative.dev,domainmappings.serving.knative.dev,images.caching.internal.knative.dev,ingresses.networking.internal.knative.dev,metrics.autoscaling.internal.knative.dev,podautoscalers.autoscaling.internal.knative.dev,revisions.serving.knative.dev,routes.serving.knative.dev,serverlessservices.networking.internal.knative.dev,services.serving.knative.dev \
    -A || true
}

create_kind_cluster() {
  log_info "Creating kind cluster ${CLUSTER_NAME}"

  if kind get clusters | grep -q "${CLUSTER_NAME}"; then
    log_error "kind cluster ${CLUSTER_NAME} already exists"
    exit 1
  fi

  kind create cluster \
    --name="${CLUSTER_NAME}" \
    --config="${SCRIPT_DIR}/kind.yaml" \
    --image="kindest/node:${K8S_VERSION}" \
    --wait=60s

  CLUSTER_CREATED=true
  echo
}

install_knative_crds() {
  log_info "Installing local Knative CRD fixtures"
  kubectl apply -f "${ROOT_DIR}/${CRD_FILE}"

  for crd in \
    certificates.networking.internal.knative.dev \
    clusterdomainclaims.networking.internal.knative.dev \
    configurations.serving.knative.dev \
    domainmappings.serving.knative.dev \
    images.caching.internal.knative.dev \
    ingresses.networking.internal.knative.dev \
    metrics.autoscaling.internal.knative.dev \
    podautoscalers.autoscaling.internal.knative.dev \
    revisions.serving.knative.dev \
    routes.serving.knative.dev \
    serverlessservices.networking.internal.knative.dev \
    services.serving.knative.dev; do
    kubectl wait --for=condition=Established --timeout=120s "crd/${crd}"
  done

  echo
}

ensure_namespace() {
  log_info "Ensuring namespace ${E2E_NAMESPACE} exists"
  kubectl get namespace "${E2E_NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${E2E_NAMESPACE}"
  echo
}

install_chart() {
  local helm_args=(
    upgrade
    --install
    "${RELEASE_NAME}"
    "${ROOT_DIR}"
    --namespace "${E2E_NAMESPACE}"
    -f "${ROOT_DIR}/${VALUES_FILE}"
    --wait
    --timeout 300s
  )

  if [ "$#" -gt 0 ]; then
    helm_args+=("$@")
  fi

  log_info "Building chart dependencies"
  helm dependency build "${ROOT_DIR}"
  echo

  log_info "Installing chart with Helm"
  helm "${helm_args[@]}"
  echo
}

verify_release_resources() {
  log_info "Verifying installed Knative resources"
  kubectl get clusterdomainclaims.networking.internal.knative.dev e2e.models.example.com
  kubectl -n "${E2E_NAMESPACE}" get certificates.networking.internal.knative.dev e2e-cert
  kubectl -n "${E2E_NAMESPACE}" get configurations.serving.knative.dev e2e-config
  kubectl -n "${E2E_NAMESPACE}" get domainmappings.serving.knative.dev e2e.models.example.com
  kubectl -n "${E2E_NAMESPACE}" get images.caching.internal.knative.dev e2e-image
  kubectl -n "${E2E_NAMESPACE}" get ingresses.networking.internal.knative.dev e2e-ingress
  kubectl -n "${E2E_NAMESPACE}" get metrics.autoscaling.internal.knative.dev e2e-metric
  kubectl -n "${E2E_NAMESPACE}" get podautoscalers.autoscaling.internal.knative.dev e2e-pa
  kubectl -n "${E2E_NAMESPACE}" get revisions.serving.knative.dev e2e-revision
  kubectl -n "${E2E_NAMESPACE}" get routes.serving.knative.dev e2e-route
  kubectl -n "${E2E_NAMESPACE}" get serverlessservices.networking.internal.knative.dev e2e-sks
  kubectl -n "${E2E_NAMESPACE}" get service.serving.knative.dev e2e-service
  echo
}

parse_args() {
  for arg in "$@"; do
    case "${arg}" in
      -h|--help)
        show_help
        exit 0
        ;;
    esac
  done
}

main() {
  parse_args "$@"
  verify_prerequisites

  trap cleanup EXIT

  create_kind_cluster
  install_knative_crds
  ensure_namespace
  install_chart "$@"
  verify_release_resources

  log_info "End-to-end checks completed successfully"
}

main "$@"
