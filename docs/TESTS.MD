# Tests

This chart uses three layers:

- `tests/units/` for fast `helm-unittest` suites and backward-compatibility checks
- `tests/smokes/` for render-path checks without a live cluster
- `tests/e2e/` for local `kind` installation checks

## Unit Tests

The unit layer verifies:

- default empty rendering
- helper-driven label and annotation merges
- namespace fallback for namespaced resources
- omitted namespace for `ClusterDomainClaim`
- example resource rendering from `values.yaml.example`

## Smoke Tests

The smoke suite verifies:

- default empty rendering
- schema enforcement for missing `name`
- rendering contract behavior
- example rendering across all 12 supported kinds
- optional `kubeconform` execution

## E2E Tests

The e2e runner:

1. Creates a disposable `kind` cluster.
2. Installs local CRD fixtures from [tests/e2e/crds.yaml](../tests/e2e/crds.yaml).
3. Installs the chart with [tests/e2e/values/install.values.yaml](../tests/e2e/values/install.values.yaml).
4. Verifies that all rendered Knative resources exist in the API server.
