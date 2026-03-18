from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from tests.smokes.steps import chart, helm, kubeconform, render, system

SCENARIO_ALIASES = {
    "schema-invalid-missing-name": "schema-invalid-array-contract",
}


@dataclass
class SmokeContext:
    repo_root: Path
    workdir: Path
    chart_dir: Path
    render_dir: Path
    release_name: str
    namespace: str
    kube_version: str
    kubeconform_bin: str
    schema_location: str
    skip_kinds: str

    @property
    def example_values(self) -> Path:
        return self.repo_root / "values.yaml.example"

    @property
    def rendering_contract_values(self) -> Path:
        return self.repo_root / "tests" / "smokes" / "fixtures" / "rendering-contract.values.yaml"

    @property
    def invalid_array_contract_values(self) -> Path:
        return self.repo_root / "tests" / "smokes" / "fixtures" / "invalid-array-contract.values.yaml"


def check_default_empty(context: SmokeContext) -> None:
    helm.lint(context.chart_dir, workdir=context.workdir)
    output_path = context.render_dir / "default-empty.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        output_path=output_path,
        workdir=context.workdir,
    )
    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 0)


def check_schema_invalid_array_contract(context: SmokeContext) -> None:
    result = helm.lint(
        context.chart_dir,
        values_file=context.invalid_array_contract_values,
        workdir=context.workdir,
        check=False,
    )
    if result.returncode == 0:
        raise system.TestFailure(
            "helm lint unexpectedly succeeded for array-based resource values"
        )

    combined_output = f"{result.stdout}\n{result.stderr}"
    if "array" not in combined_output or "object" not in combined_output:
        raise system.TestFailure(
            "helm lint failed for invalid values, but the error does not mention the array-to-object contract mismatch"
        )


def check_rendering_contract(context: SmokeContext) -> None:
    helm.lint(
        context.chart_dir,
        values_file=context.rendering_contract_values,
        workdir=context.workdir,
    )
    output_path = context.render_dir / "rendering-contract.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.rendering_contract_values,
        output_path=output_path,
        workdir=context.workdir,
    )

    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 2)

    service = render.select_document(documents, kind="Service", name="merged-service")
    render.assert_path(service, "apiVersion", "example.net/v1alpha1")
    render.assert_path(service, "metadata.namespace", context.namespace)
    render.assert_path(
        service,
        "metadata.labels[app.kubernetes.io/name]",
        "knative-platform",
    )
    render.assert_path(service, "metadata.labels.platform", "knative")
    render.assert_path(service, "metadata.labels.component", "service")
    render.assert_path(service, "metadata.labels.tier", "public")
    render.assert_path(service, "metadata.annotations.team", "platform")
    render.assert_path(service, "metadata.annotations.note", "public-entrypoint")
    render.assert_path(
        service,
        "spec.template.spec.containers[0].image",
        "ghcr.io/example/predictor:1.0.0",
    )

    cluster_domain_claim = render.select_document(
        documents, kind="ClusterDomainClaim", name="models.internal.example.com"
    )
    render.assert_path(
        cluster_domain_claim, "apiVersion", "networking.internal.knative.dev/v1beta1"
    )
    render.assert_path_missing(cluster_domain_claim, "metadata.namespace")
    render.assert_path(
        cluster_domain_claim,
        "metadata.labels[app.kubernetes.io/name]",
        "knative-platform",
    )
    render.assert_path(
        cluster_domain_claim, "metadata.labels.component", "cluster-domain-claim"
    )
    render.assert_path(cluster_domain_claim, "metadata.annotations.team", "platform")
    render.assert_path(cluster_domain_claim, "metadata.annotations.note", "cluster-scope")
    render.assert_path(
        cluster_domain_claim, "spec.namespace", "smoke-namespace"
    )


def check_example_render(context: SmokeContext) -> None:
    helm.lint(
        context.chart_dir,
        values_file=context.example_values,
        workdir=context.workdir,
    )
    output_path = context.render_dir / "example-render.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.example_values,
        output_path=output_path,
        workdir=context.workdir,
    )

    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 12)
    render.assert_kinds(
        documents,
        {
            "Certificate",
            "ClusterDomainClaim",
            "Configuration",
            "DomainMapping",
            "Image",
            "Ingress",
            "Metric",
            "PodAutoscaler",
            "Revision",
            "Route",
            "ServerlessService",
            "Service",
        },
    )

    cluster_domain_claim = render.select_document(
        documents, kind="ClusterDomainClaim", name="models.example.com"
    )
    render.assert_path_missing(cluster_domain_claim, "metadata.namespace")

    service = render.select_document(documents, kind="Service", name="sklearn-svc")
    render.assert_path(service, "metadata.namespace", "kserve-user")
    render.assert_path(service, "spec.template.spec.containers[0].env[0].value", "sklearn")

    configuration = render.select_document(
        documents, kind="Configuration", name="sklearn-config"
    )
    render.assert_path(
        configuration, "spec.template.spec.containers[0].ports[0].containerPort", 8080
    )

    ingress = render.select_document(documents, kind="Ingress", name="sklearn-ingress")
    render.assert_path(
        ingress, "spec.rules[0].http.paths[0].splits[0].serviceName", "activator-service"
    )

    route = render.select_document(documents, kind="Route", name="sklearn-route")
    render.assert_path(route, "spec.traffic[0].revisionName", "sklearn-config-00001")


def check_example_kubeconform(context: SmokeContext) -> None:
    output_path = context.render_dir / "example-kubeconform.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.example_values,
        output_path=output_path,
        workdir=context.workdir,
    )
    kubeconform.validate(
        manifest_path=output_path,
        kube_version=context.kube_version,
        kubeconform_bin=context.kubeconform_bin,
        schema_location=context.schema_location,
        skip_kinds=context.skip_kinds,
    )


SCENARIOS: list[tuple[str, Callable[[SmokeContext], None]]] = [
    ("default-empty", check_default_empty),
    ("schema-invalid-array-contract", check_schema_invalid_array_contract),
    ("rendering-contract", check_rendering_contract),
    ("example-render", check_example_render),
    ("example-kubeconform", check_example_kubeconform),
]


def run_smoke_suite(args) -> int:
    scenario_map = dict(SCENARIOS)
    requested = args.scenario or ["all"]
    if "all" in requested:
        selected = [name for name, _ in SCENARIOS]
    else:
        selected = []
        for name in requested:
            normalized = SCENARIO_ALIASES.get(name, name)
            if normalized not in selected:
                selected.append(normalized)

    repo_root = Path(args.chart_dir).resolve()
    workdir, chart_dir = chart.stage_chart(repo_root, args.workdir)
    context = SmokeContext(
        repo_root=repo_root,
        workdir=workdir,
        chart_dir=chart_dir,
        render_dir=workdir / "rendered",
        release_name=args.release_name,
        namespace=args.namespace,
        kube_version=args.kube_version,
        kubeconform_bin=args.kubeconform_bin,
        schema_location=args.schema_location,
        skip_kinds=args.skip_kinds,
    )
    context.render_dir.mkdir(parents=True, exist_ok=True)

    failures: list[tuple[str, str]] = []
    try:
        for name in selected:
            system.log(f"=== scenario: {name} ===")
            try:
                scenario_map[name](context)
            except Exception as exc:
                failures.append((name, str(exc)))
                system.log(f"FAILED: {name}: {exc}")
            else:
                system.log(f"PASSED: {name}")
    finally:
        if args.keep_workdir:
            system.log(f"workdir kept at {workdir}")
        else:
            chart.cleanup(workdir)

    if failures:
        system.log("=== summary: failures ===")
        for name, message in failures:
            system.log(f"- {name}: {message}")
        return 1

    system.log("=== summary: all smoke scenarios passed ===")
    return 0
