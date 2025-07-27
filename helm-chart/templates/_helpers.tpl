{{/*
Expand the name of the chart.
*/}}
{{- define "l2scan-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "l2scan-stack.fullname" -}}
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
{{- define "l2scan-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "l2scan-stack.labels" -}}
helm.sh/chart: {{ include "l2scan-stack.chart" . }}
{{ include "l2scan-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "l2scan-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "l2scan-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "l2scan-stack.frontend.labels" -}}
{{ include "l2scan-stack.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "l2scan-stack.frontend.selectorLabels" -}}
{{ include "l2scan-stack.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Indexer labels
*/}}
{{- define "l2scan-stack.indexer.labels" -}}
{{ include "l2scan-stack.labels" . }}
app.kubernetes.io/component: indexer
{{- end }}

{{/*
Indexer selector labels
*/}}
{{- define "l2scan-stack.indexer.selectorLabels" -}}
{{ include "l2scan-stack.selectorLabels" . }}
app.kubernetes.io/component: indexer
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "l2scan-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "l2scan-stack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Frontend image name
*/}}
{{- define "l2scan-stack.frontend.image" -}}
{{- $registryName := .Values.frontend.image.registry -}}
{{- $repositoryName := .Values.frontend.image.repository -}}
{{- $tag := .Values.frontend.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
    {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end }}

{{/*
Indexer image name
*/}}
{{- define "l2scan-stack.indexer.image" -}}
{{- $registryName := .Values.indexer.image.registry -}}
{{- $repositoryName := .Values.indexer.image.repository -}}
{{- $tag := .Values.indexer.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
    {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end }}

{{/*
PostgreSQL connection URL
*/}}
{{- define "l2scan-stack.postgresql.url" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "postgresql://%s:%s@%s-postgresql:5432/%s" .Values.postgresql.auth.username .Values.postgresql.auth.password .Release.Name .Values.postgresql.auth.database -}}
{{- else -}}
{{- .Values.frontend.env.DATABASE_URL -}}
{{- end -}}
{{- end }}

{{/*
Redis connection URL
*/}}
{{- define "l2scan-stack.redis.url" -}}
{{- if .Values.redis.enabled -}}
{{- if .Values.redis.auth.enabled -}}
{{- printf "redis://:%s@%s-redis-master:6379" .Values.redis.auth.password .Release.Name -}}
{{- else -}}
{{- printf "redis://%s-redis-master:6379" .Release.Name -}}
{{- end -}}
{{- else -}}
{{- .Values.frontend.env.REDIS_URL -}}
{{- end -}}
{{- end }}

{{/*
Verifier connection URL
*/}}
{{- define "l2scan-stack.verifier.url" -}}
{{- if .Values.verifier.enabled -}}
{{- printf "http://%s-verifier:%d" (include "l2scan-stack.fullname" .) (.Values.verifier.service.port | int) -}}
{{- else -}}
{{- .Values.frontend.env.VERIFICATION_URL -}}
{{- end -}}
{{- end }}