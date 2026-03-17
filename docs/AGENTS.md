# Agent Guide

This repository contains one Helm chart that renders Knative Serving and Knative internal resources through a generic values contract.

## Working Rules

- Keep the root chart layout simple: `Chart.yaml`, `values.yaml`, `values.schema.json`, `values.yaml.example`, `templates/`, `tests/`, and `docs/`.
- Keep templates thin. Shared behavior belongs in [templates/_helpers.tpl](../templates/_helpers.tpl).
- Keep defaults minimal. Base [values.yaml](../values.yaml) should render nothing.
- Keep [values.yaml.example](../values.yaml.example) representative and make sure every supported kind appears at least once.
- When changing the values contract, update schema, tests, and docs in the same change.

## Test Layers

- `tests/units/`: helper behavior, namespace handling, API version overrides, and example fixtures.
- `tests/smokes/`: render-path validation and schema checks without a cluster.
- `tests/e2e/`: local `kind` install using CRD fixtures from [tests/e2e/crds.yaml](../tests/e2e/crds.yaml).

## Final Verification

Prefer this compact pass before finishing:

```bash
git diff --check
helm lint . -f values.yaml.example
helm template smoke . -f values.yaml.example >/dev/null
bash -n tests/e2e/test-e2e.sh
sh -n tests/units/backward_compatibility_test.sh
python3 -m py_compile tests/smokes/helpers/argparser.py tests/smokes/run/smoke.py tests/smokes/scenarios/smoke.py tests/smokes/steps/*.py
```
