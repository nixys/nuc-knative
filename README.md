# NUC Knative

Helm chart for rendering Knative Serving and Knative internal resources often used around KServe installations.

The chart does not install Knative or KServe CRDs. It only renders resource instances for CRDs that already exist in the target cluster.

## Supported Resources

- `Certificate`
- `ClusterDomainClaim`
- `Configuration`
- `DomainMapping`
- `Image`
- `Ingress`
- `Metric`
- `PodAutoscaler`
- `Revision`
- `Route`
- `ServerlessService`
- `Service`

## Quick Start

```bash
helm template nuc-knative . -f values.yaml.example
helm install nuc-knative . --namespace kserve-user --create-namespace -f values.yaml.example
```

## Values

Each supported resource kind is represented by one top-level list in `values.yaml`:

- `certificates`
- `clusterDomainClaims`
- `configurations`
- `domainMappings`
- `images`
- `ingresses`
- `metrics`
- `podAutoscalers`
- `revisions`
- `routes`
- `serverlessServices`
- `services`

Every item supports `name`, `namespace`, `labels`, `annotations`, `apiVersion`, `spec`, and `status`.

## Testing

```bash
make lint
make test-unit
make test-compat
make test-smoke
make test-e2e
```

`tests/e2e/` installs local CRD fixtures for the required Knative resource kinds and then verifies that Helm can create all example resources in a disposable `kind` cluster.
