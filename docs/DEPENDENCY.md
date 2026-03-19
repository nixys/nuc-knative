# Development Dependencies

This repository is built around these entry points:

- `make lint`
- `make docs`
- `make test-unit`
- `make test-compat`
- `make test-smoke`
- `make test-e2e`

## Dependency Matrix

| Tool | Why it is needed |
|------|------------------|
| `git` | repository operations and compatibility checks |
| `helm` | linting, templating, install flows, `helm-unittest` plugin host |
| `helm-unittest` | unit test plugin |
| `python3` | smoke-test runner |
| `PyYAML` | smoke-test dependency |
| `kubeconform` | optional CRD manifest validation in smoke tests |
| `docker` | `kind` runtime and optional `helm-docs` fallback |
| `kubectl` | e2e cluster verification |
| `kind` | disposable local Kubernetes cluster for e2e |
| `pre-commit` | local hook manager |
| `helm-docs` | README generator |

## Repository Defaults

- `kindest/node`: `v1.35.0`
- `kubeconform`: `v0.6.7`

The e2e runner uses local CRD fixtures from [tests/e2e/crds.yaml](../tests/e2e/crds.yaml), so it does not need to download Knative bundles during the test itself.
