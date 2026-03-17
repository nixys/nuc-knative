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

## Values Model

Each top-level list in [values.yaml](values.yaml) maps to one resource kind:

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

Each list item uses the same contract:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Resource name.  |
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
| certificates | list | `[]` | Certificate resources to render. |
| clusterDomainClaims | list | `[]` | ClusterDomainClaim resources to render. |
| commonAnnotations | object | `{}` | Extra annotations applied to every rendered resource. |
| commonLabels | object | `{}` | Extra labels applied to every rendered resource. |
| configurations | list | `[]` | Configuration resources to render. |
| domainMappings | list | `[]` | DomainMapping resources to render. |
| images | list | `[]` | Image resources to render. |
| ingresses | list | `[]` | Ingress resources to render. |
| metrics | list | `[]` | Metric resources to render. |
| nameOverride | string | `""` | Override the default chart label name if needed. |
| podAutoscalers | list | `[]` | PodAutoscaler resources to render. |
| revisions | list | `[]` | Revision resources to render. |
| routes | list | `[]` | Route resources to render. |
| serverlessServices | list | `[]` | ServerlessService resources to render. |
| services | list | `[]` | Service resources to render. |

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
