{{/*
Resource name. Kept as .Release.Name so existing objects are not renamed.
*/}}
{{- define "simple-whoami.fullname" -}}
{{- .Release.Name -}}
{{- end -}}

{{/*
Selector labels.
Do NOT change these: spec.selector is immutable on an existing Deployment and a
Service selector change silently detaches all endpoints.
*/}}
{{- define "simple-whoami.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Metadata labels. Safe to extend, unlike the selector labels above.
*/}}
{{- define "simple-whoami.labels" -}}
{{ include "simple-whoami.selectorLabels" . }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
{{- with .Values.extraLabels }}
{{ toYaml . | trim }}
{{- end }}
{{- end -}}

{{/*
Image reference. A digest pins the exact build and wins over the tag.
*/}}
{{- define "simple-whoami.image" -}}
{{- if .Values.image.digest -}}
{{ .Values.image.repository }}@{{ .Values.image.digest }}
{{- else -}}
{{ .Values.image.repository }}:{{ required "image.tag or image.digest must be set" .Values.image.tag }}
{{- end -}}
{{- end -}}

{{/*
Pull policy. A moving tag must be re-pulled, an immutable one never has to be.
*/}}
{{- define "simple-whoami.pullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{ .Values.image.pullPolicy }}
{{- else if or .Values.image.digest (ne .Values.image.tag "latest") -}}
IfNotPresent
{{- else -}}
Always
{{- end -}}
{{- end -}}

{{/*
TLS secret name, per release so two environments never collide.
*/}}
{{- define "simple-whoami.tlsSecretName" -}}
{{- default (printf "%s-tls" .Release.Name) .Values.ingress.tls.secretName -}}
{{- end -}}

{{/*
Public hostname. Empty would render a rule without a host, which Traefik turns
into a catch-all router that answers for every hostname in the cluster.
*/}}
{{- define "simple-whoami.host" -}}
{{- required "PublicDomain must be set (e.g. -f values-prod.yaml)" .Values.PublicDomain -}}
{{- end -}}
