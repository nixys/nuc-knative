# Agent Guide

This file is a reusable baseline for Helm chart repositories that follow a single-chart layout with layered tests under `tests/units`, `tests/e2e`, and `tests/smokes`.

Adapt names, chart-specific commands, and controller details to the target project, but keep the structure and expectations consistent unless the repository clearly uses another pattern.

## Repository Shape

Prefer a single root chart with this baseline structure:

```text
.
├── Chart.yaml
├── values.yaml
├── values.schema.json
├── values.yaml.example
├── templates/
├── tests/
│   ├── units/
│   ├── e2e/
│   └── smokes/
└── docs/
```

Keep documentation and automation aligned with the actual tree. If a directory or workflow is removed, update both the docs and CI in the same change.

## Documentation Rules

- Keep one root `README.md` as the primary entry point.
- Keep test-layer details in `docs/TESTS.MD`.
- Use relative repository links in Markdown, not workstation-specific absolute paths.
- Prefer describing the current repository state over aspirational tooling that is not actually wired in.
- If a workflow is local-only, state that explicitly.

## Chart Design Expectations

- Keep templates thin and deterministic.
- Centralize shared rendering logic in `templates/_helpers.tpl` when repetition appears.
- Prefer generic resource contracts when the chart is intended to pass through raw Kubernetes or CRD specs.
- Validate the values contract with `values.schema.json` when possible.
- Avoid managing `status` in production workflows unless the chart is explicitly intended for fixtures or synthetic manifests.

## Test Layers

### Unit Tests

Use `helm-unittest` for chart-owned rendering behavior:

- helper behavior
- defaulting
- label and annotation merges
- namespace handling
- API version overrides
- representative manifests from example values

Keep unit suites compact. Do not mirror large CRD payloads field by field unless the chart itself transforms them.

### Smoke Tests

Use smoke tests for render-path validation without a live cluster:

- default empty render
- schema enforcement from `values.schema.json`
- representative example rendering
- optional `kubeconform` validation

Prefer small reusable helpers around `helm`, file staging, and manifest assertions.

### E2E Tests

Use `kind`-based or cluster-backed e2e tests only when they validate something that unit and smoke tests cannot:

- installation into a real API server
- CRD presence and compatibility
- end-to-end Helm install or upgrade flows

If e2e requires Docker, kind, or privileged runners, it is acceptable to keep it local-only and expose it through a `Makefile`.

## CI Guidance

CI should cover the lightweight checks by default:

- lint
- unit tests
- smoke tests
- backward compatibility rendering
- manifest rendering
- schema validation

Add e2e to CI only when the target runner environment actually supports it. Avoid documenting e2e CI jobs that cannot run on the repository's real runners.

## Makefile Guidance

If the repository ships a `Makefile`, use it as a thin local wrapper around existing scripts, not as a second source of truth.

Good targets:

- `make lint`
- `make test-unit`
- `make test-compat`
- `make test-smoke`
- `make test-smoke-fast`
- `make test-e2e`
- `make test-e2e-debug`
- `make test-e2e-help`

Keep target names predictable and scoped to the workflows that already exist in the repository.

## Cleanup Rules

- Remove generated files such as `__pycache__`, `*.pyc`, temporary renders, and unused local tooling configs.
- Delete outdated docs instead of leaving duplicates.
- If a config file is not referenced by CI, scripts, or documented local workflows, treat it as a removal candidate.
- After cleanup, run a final pass over Markdown so the repository reads as one coherent system.

## Final Verification

Before finishing a change in a similar repository, prefer to run a compact validation set such as:

```bash
git diff --check
helm lint . -f values.yaml.example
helm template <release> . -f values.yaml.example
bash -n tests/e2e/test-e2e.sh
sh -n tests/units/backward_compatibility_test.sh
python3 -m py_compile tests/smokes/helpers/argparser.py tests/smokes/run/smoke.py tests/smokes/scenarios/smoke.py tests/smokes/steps/*.py
```

Add or swap commands to match the actual repository toolchain, but keep the idea: syntax, renderability, and documentation must all agree by the end of the change.
