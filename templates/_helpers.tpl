{{- define "nuc-knative.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nuc-knative.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nuc-knative.labels" -}}
app.kubernetes.io/name: {{ include "nuc-knative.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "nuc-knative.chart" . }}
{{- end -}}

{{- define "nuc-knative.renderResource" -}}
{{- $root := .root -}}
{{- $item := .item -}}
{{- $resourceKey := .resourceKey -}}
{{- $resourceName := .resourceName -}}
{{- $defaultLabels := include "nuc-knative.labels" $root | fromYaml -}}
{{- $labels := mustMergeOverwrite (dict) $defaultLabels ($root.Values.commonLabels | default dict) ($item.labels | default dict) -}}
{{- $annotations := mustMergeOverwrite (dict) ($root.Values.commonAnnotations | default dict) ($item.annotations | default dict) -}}
apiVersion: {{ default .defaultApiVersion $item.apiVersion }}
kind: {{ .kind }}
metadata:
  name: {{ required (printf "%s key is required" $resourceKey) $resourceName }}
  {{- if .namespaced }}
  namespace: {{ default $root.Release.Namespace $item.namespace }}
  {{- end }}
  labels:
{{ toYaml $labels | nindent 4 }}
  {{- if $annotations }}
  annotations:
{{ toYaml $annotations | nindent 4 }}
  {{- end }}
{{- with $item.spec }}
spec:
{{ toYaml . | nindent 2 }}
{{- end }}
{{- with $item.status }}
status:
{{ toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "nuc-knative.renderResourceCollection" -}}
{{- $root := .root -}}
{{- $items := .items | default dict -}}
{{- $resourceKey := .resourceKey -}}
{{- $defaultApiVersion := .defaultApiVersion -}}
{{- $kind := .kind -}}
{{- $namespaced := .namespaced -}}
{{- $documents := list -}}
{{- range $resourceName, $item := $items -}}
{{- if kindIs "map" $item -}}
{{- $documents = append $documents (include "nuc-knative.renderResource" (dict "root" $root "item" $item "resourceKey" (printf "%s[%q]" $resourceKey $resourceName) "resourceName" $resourceName "defaultApiVersion" $defaultApiVersion "kind" $kind "namespaced" $namespaced)) -}}
{{- end -}}
{{- end -}}
{{- join "\n---\n" $documents -}}
{{- end -}}
