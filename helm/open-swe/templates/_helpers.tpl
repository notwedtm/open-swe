{{/*
Expand the name of the chart.
*/}}
{{- define "open-swe.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "open-swe.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "open-swe.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "open-swe.labels" -}}
helm.sh/chart: {{ include "open-swe.chart" . }}
{{ include "open-swe.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "open-swe.selectorLabels" -}}
app.kubernetes.io/name: {{ include "open-swe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "open-swe.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "open-swe.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the image name for the Open SWE agent
*/}}
{{- define "open-swe.agent.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.openSwe.image.repository -}}
{{- $tag := .Values.openSwe.image.tag | default .Chart.AppVersion -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end }}

{{/*
Generate the image name for the web application
*/}}
{{- define "open-swe.web.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.web.image.repository -}}
{{- $tag := .Values.web.image.tag | default .Chart.AppVersion -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end }}

{{/*
Generate common annotations
*/}}
{{- define "open-swe.annotations" -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate pod annotations
*/}}
{{- define "open-swe.podAnnotations" -}}
{{- with .Values.podAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate common pod labels
*/}}
{{- define "open-swe.podLabels" -}}
{{- with .Values.podLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate the ConfigMap name
*/}}
{{- define "open-swe.configMapName" -}}
{{- printf "%s-config" (include "open-swe.fullname" .) }}
{{- end }}

{{/*
Generate the Secret name
*/}}
{{- define "open-swe.secretName" -}}
{{- printf "%s-secrets" (include "open-swe.fullname" .) }}
{{- end }}

{{/*
Generate agent service name
*/}}
{{- define "open-swe.agent.serviceName" -}}
{{- printf "%s-agent" (include "open-swe.fullname" .) }}
{{- end }}

{{/*
Generate web service name
*/}}
{{- define "open-swe.web.serviceName" -}}
{{- printf "%s-web" (include "open-swe.fullname" .) }}
{{- end }}

{{/*
Generate agent deployment name
*/}}
{{- define "open-swe.agent.deploymentName" -}}
{{- printf "%s-agent" (include "open-swe.fullname" .) }}
{{- end }}

{{/*
Generate web deployment name
*/}}
{{- define "open-swe.web.deploymentName" -}}
{{- printf "%s-web" (include "open-swe.fullname" .) }}
{{- end }}

{{/*
Validate required values
*/}}
{{- define "open-swe.validateValues" -}}
{{- if not .Values.secrets.secretsEncryptionKey -}}
{{- fail "secrets.secretsEncryptionKey is required" -}}
{{- end -}}
{{- if not .Values.secrets.anthropicApiKey -}}
{{- if not .Values.secrets.openaiApiKey -}}
{{- fail "At least one LLM provider API key (anthropicApiKey or openaiApiKey) is required" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Generate resource limits and requests
*/}}
{{- define "open-swe.resources" -}}
{{- if .resources -}}
{{- toYaml .resources -}}
{{- end -}}
{{- end }}

{{/*
Generate security context
*/}}
{{- define "open-swe.securityContext" -}}
{{- if .securityContext -}}
{{- toYaml .securityContext -}}
{{- end -}}
{{- end }}

{{/*
Generate pod security context
*/}}
{{- define "open-swe.podSecurityContext" -}}
{{- if .podSecurityContext -}}
{{- toYaml .podSecurityContext -}}
{{- end -}}
{{- end }}
