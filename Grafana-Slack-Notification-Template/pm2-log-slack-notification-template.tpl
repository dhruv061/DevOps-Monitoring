{{ define "pm2_log.title" }}
{{ range .Alerts }}
{{ if eq .Status "firing" }}🚨 [Urgent]{{ else }}✅ [RESLVED]{{ end }} Alert Name: {{ .Labels.alertname }}  
{{ end }}
{{ end }}

{{ define "pm2_log..message" }}
{{ range .Alerts }}
*JOB:* {{ .Labels.job }}  
🔗 *View in Grafana:* https://insights.webdevprojects.cloud  

*Labels:*  
{{ if .Labels.job }}- *job:* {{ .Labels.job }}{{ end }}  
{{ if .Labels.grafana_folder }}- *grafana_folder:* {{ .Labels.grafana_folder }}{{ end }}  
{{ if .Labels.filename }}- *filename:* {{ .Labels.filename }}{{ end }}

{{ end }}
{{ end }}