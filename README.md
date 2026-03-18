# NUC Knative

Helm chart for rendering Knative Serving and Knative internal resources often used around KServe installations.

The chart does not install Knative or KServe CRDs. It only renders resource instances for CRDs that already exist in the target cluster.

## Quick Start

Render the example configuration:

```bash
helm template nuc-knative . -f values.yaml.example
```

Install the chart:

```bash
helm install nuc-knative . \
  --namespace kserve-user \
  --create-namespace \
  -f values.yaml.example
```

## Supported Resources

| Kind | Values key | Scope | Default apiVersion |
|------|------------|-------|--------------------|
| `Certificate` | `certificates` | Namespaced | `networking.internal.knative.dev/v1alpha1` |
| `ClusterDomainClaim` | `clusterDomainClaims` | Cluster | `networking.internal.knative.dev/v1alpha1` |
| `Configuration` | `configurations` | Namespaced | `serving.knative.dev/v1` |
| `DomainMapping` | `domainMappings` | Namespaced | `serving.knative.dev/v1beta1` |
| `Image` | `images` | Namespaced | `caching.internal.knative.dev/v1alpha1` |
| `Ingress` | `ingresses` | Namespaced | `networking.internal.knative.dev/v1alpha1` |
| `Metric` | `metrics` | Namespaced | `autoscaling.internal.knative.dev/v1alpha1` |
| `PodAutoscaler` | `podAutoscalers` | Namespaced | `autoscaling.internal.knative.dev/v1alpha1` |
| `Revision` | `revisions` | Namespaced | `serving.knative.dev/v1` |
| `Route` | `routes` | Namespaced | `serving.knative.dev/v1` |
| `ServerlessService` | `serverlessServices` | Namespaced | `networking.internal.knative.dev/v1alpha1` |
| `Service` | `services` | Namespaced | `serving.knative.dev/v1` |

## Values Model

Each top-level map in [values.yaml](values.yaml) maps to one resource kind:

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

Each map entry uses the same contract. The entry key becomes the resource name:

| Field | Required | Description |
|-------|----------|-------------|
| `namespace` | no | Namespace for namespaced resources. Defaults to the Helm release namespace. Ignored for cluster-scoped resources. |
| `labels` | no | Labels merged on top of built-in chart labels and `commonLabels`. |
| `annotations` | no | Annotations merged on top of `commonAnnotations`. |
| `apiVersion` | no | Per-resource API version override. |
| `spec` | no | Raw resource spec rendered as-is. |
| `status` | no | Optional raw status block for fixtures and synthetic manifests. |

Global controls:

- `nameOverride`
- `commonLabels`
- `commonAnnotations`
- `apiVersions.*`

Nested contract fields are exposed in the generated Helm values table under `resourceItemContract.*`. This block is documentation-only and is ignored by templates.

## Helm Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiVersions.certificate | string | `"networking.internal.knative.dev/v1alpha1"` | Default apiVersion for Certificate resources. |
| apiVersions.clusterDomainClaim | string | `"networking.internal.knative.dev/v1alpha1"` | Default apiVersion for ClusterDomainClaim resources. |
| apiVersions.configuration | string | `"serving.knative.dev/v1"` | Default apiVersion for Configuration resources. |
| apiVersions.domainMapping | string | `"serving.knative.dev/v1beta1"` | Default apiVersion for DomainMapping resources. |
| apiVersions.image | string | `"caching.internal.knative.dev/v1alpha1"` | Default apiVersion for Image resources. |
| apiVersions.ingress | string | `"networking.internal.knative.dev/v1alpha1"` | Default apiVersion for Ingress resources. |
| apiVersions.metric | string | `"autoscaling.internal.knative.dev/v1alpha1"` | Default apiVersion for Metric resources. |
| apiVersions.podAutoscaler | string | `"autoscaling.internal.knative.dev/v1alpha1"` | Default apiVersion for PodAutoscaler resources. |
| apiVersions.revision | string | `"serving.knative.dev/v1"` | Default apiVersion for Revision resources. |
| apiVersions.route | string | `"serving.knative.dev/v1"` | Default apiVersion for Route resources. |
| apiVersions.serverlessService | string | `"networking.internal.knative.dev/v1alpha1"` | Default apiVersion for ServerlessService resources. |
| apiVersions.service | string | `"serving.knative.dev/v1"` | Default apiVersion for Service resources. |
| certificates | object | `{}` | Certificate resources keyed by resource name. |
| clusterDomainClaims | object | `{}` | ClusterDomainClaim resources keyed by resource name. |
| commonAnnotations | object | `{}` | Extra annotations applied to every rendered resource. |
| commonLabels | object | `{}` | Extra labels applied to every rendered resource. |
| configurations | object | `{}` | Configuration resources keyed by resource name. |
| domainMappings | object | `{}` | DomainMapping resources keyed by resource name. |
| images | object | `{}` | Image resources keyed by resource name. |
| ingresses | object | `{}` | Ingress resources keyed by resource name. |
| metrics | object | `{}` | Metric resources keyed by resource name. |
| nameOverride | string | `""` | Override the default chart label name if needed. |
| podAutoscalers | object | `{}` | PodAutoscaler resources keyed by resource name. |
| resourceItemContract | object | `{"annotations":{"exampleKey":"example-value"},"apiVersion":"example.group/v1alpha1","labels":{"exampleKey":"example-value"},"namespace":"example-namespace","spec":{"exampleField":"example-value"},"status":{"exampleField":"example-value"}}` | Documentation-only contract for a single resource map entry. The map key becomes the resource name. Templates ignore this block; it exists so helm-docs can describe nested fields such as `namespace`, `labels`, `annotations`, `apiVersion`, `spec`, and `status`. |
| resourceItemContract.annotations.exampleKey | string | `"example-value"` | Example annotation value. Real items may use arbitrary keys and values. |
| resourceItemContract.apiVersion | string | `"example.group/v1alpha1"` | Example per-resource apiVersion override. |
| resourceItemContract.labels.exampleKey | string | `"example-value"` | Example label value. Real items may use arbitrary keys and values. |
| resourceItemContract.namespace | string | `"example-namespace"` | Example namespace for namespaced resources. Cluster-scoped kinds ignore this field. |
| resourceItemContract.spec.exampleField | string | `"example-value"` | Example spec field. Replace with the real CRD spec payload for the selected kind. |
| resourceItemContract.status.exampleField | string | `"example-value"` | Example status field. Usually only useful for fixtures and synthetic manifests. |
| revisions | object | `{}` | Revision resources keyed by resource name. |
| routes | object | `{}` | Route resources keyed by resource name. |
| serverlessServices | object | `{}` | ServerlessService resources keyed by resource name. |
| services | object | `{}` | Service resources keyed by resource name. |

## Included Values Files

- [values.yaml](values.yaml): minimal defaults that render no resources.
- [values.yaml.example](values.yaml.example): one example for every supported kind.

## Testing

Representative local commands:

```bash
helm lint . -f values.yaml.example
helm template nuc-knative . -f values.yaml.example
helm unittest -f 'tests/units/*_test.yaml' .
sh tests/units/backward_compatibility_test.sh
python3 tests/smokes/run/smoke.py --scenario example-render
make test-e2e
```

Detailed test notes are in [docs/TESTS.MD](docs/TESTS.MD). Dependency setup is in [docs/DEPENDENCY.md](docs/DEPENDENCY.md).
