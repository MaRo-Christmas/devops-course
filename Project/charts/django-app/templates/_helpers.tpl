{{- define "django-app.name" -}}
django-app
{{- end -}}

{{- define "django-app.fullname" -}}
{{ include "django-app.name" . }}-{{ .Release.Name }}
{{- end -}}
