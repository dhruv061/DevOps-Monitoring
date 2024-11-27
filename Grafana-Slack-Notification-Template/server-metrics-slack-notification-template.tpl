{{ define "server_metrics.title_NEW_1732689752872" }}
{{ range .Alerts }}
  {{ if eq .Status "firing" }} 🚨 High CPU Alert! [ {{ .Labels.job }} ]🚨  
  {{ else }} ✅ CPU Alert Resolved![ {{ .Labels.job }} ] ✅  
  {{ end }}
{{ end }}
{{ end }}

{{ define "server_metrics.message_NEW_1732689752872" }}
{{ range .Alerts }}
  {{ if eq .Status "firing" }}
    🙋 *Alert Details:*  
    - *Alert Name:* {{ .Labels.alertname }}
    - *Server:*  {{ .Labels.job }}
    - *Instance:* {{ .Labels.instance }}  
    - *Folder:* {{ .Labels.grafana_folder }}  

    🔗 *View in Grafana:* https://insights.webdevprojects.cloud

    *What's Happening?*  
    ⚠️ The CPU usage on instance `{{ .Labels.instance }}` `{{ .Labels.job }}` has exceeded *80%*. Immediate action is required!
    ---
  {{ else }}
    🙋 *Resolved Alert Details:*  
    - *Alert Name:* {{ .Labels.alertname }}  
    - *Server:*  {{ .Labels.job }}
    - *Instance:* {{ .Labels.instance }}  
    - *Folder:* {{ .Labels.grafana_folder }}  

    🔗 *View in Grafana:* https://insights.webdevprojects.cloud

    🎉 *Good News!*
    The alert for CPU usage on instance `{{ .Labels.instance }}` `{{ .Labels.job }}` is no longer firing. Everything is back to normal. 🎉  
    ---
  {{ end }}
{{ end }}
{{ end }}