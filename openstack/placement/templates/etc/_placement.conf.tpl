# placement.conf
[DEFAULT]
log_config_append = /etc/{{ include "placement_project" . }}/logging.ini
state_path = /var/lib/{{ include "placement_project" . }}

memcache_servers = {{ .Chart.Name }}-memcached.{{ include "svc_fqdn" . }}:{{ .Values.memcached.memcached.port | default 11211 }}

{{- include "ini_sections.logging_format" . }}

[placement_database]
{{- if not .Values.mariadb.enabled }}
connection = mysql+pymysql://nova_api:{{.Values.mariadb.root_password | urlquery}}@nova-api-mariadb.{{.Release.Namespace}}.svc.kubernetes.{{.Values.global.region}}.{{.Values.global.tld}}/nova_api?charset=utf8
{{- else }}
connection = {{ tuple . .Values.mariadb.name .Values.global.dbUser .Values.global.dbPassword | include "db_url_mysql" }}
{{- end }}
{{- include "ini_sections.database_options_mysql" . }}


{{- include "osprofiler" . }}


{{- include "ini_sections.oslo_messaging_rabbit" .}}

[oslo_concurrency]
lock_path = /var/lib/{{ include "placement_project" . }}/tmp

[keystone_authtoken]
auth_type = v3password
auth_version = v3
auth_interface = internal
www_authenticate_uri = https://{{include "keystone_api_endpoint_host_public" .}}/v3
auth_url = {{.Values.global.keystone_api_endpoint_protocol_internal | default "http"}}://{{include "keystone_api_endpoint_host_internal" .}}:{{ .Values.global.keystone_api_port_internal | default 5000}}/v3
username = {{ .Values.global.placement_service_user | default "placement" }}{{ .Values.global.user_suffix }}
password = {{ required ".Values.global.placement_service_password is missing" .Values.global.placement_service_password }}
user_domain_name = "{{.Values.global.keystone_service_domain | default "Default" }}"
project_name = "{{.Values.global.keystone_service_project | default "service" }}"
project_domain_name = "{{.Values.global.keystone_service_domain | default "Default" }}"
region_name = {{.Values.global.region}}
memcached_servers = {{ .Chart.Name }}-memcached.{{ include "svc_fqdn" . }}:{{ .Values.memcached.memcached.port | default 11211 }}
insecure = True
token_cache_time = 600
include_service_catalog = true
service_type = compute
service_token_roles_required = True

[oslo_messaging_notifications]
driver = noop

[oslo_middleware]
enable_proxy_headers_parsing = true

[placement]
auth_type = v3password
auth_version = v3
auth_url = http://{{include "keystone_api_endpoint_host_internal" .}}:{{ .Values.global.keystone_api_port_internal | default "5000" }}/v3
username = {{.Values.global.placement_service_user}}
password = {{ required ".Values.global.placement_service_password is missing" .Values.global.placement_service_password }}
user_domain_name = "{{.Values.global.keystone_service_domain | default "Default" }}"
project_name = service
project_domain_name = "{{.Values.global.keystone_service_domain | default "Default" }}"
valid_interfaces = internal
region_name = {{.Values.global.region}}

{{- include "ini_sections.audit_middleware_notifications" . }}

{{- include "ini_sections.cache" . }}

[wsgi]
default_pool_size = {{ .Values.wsgi_default_pool_size | default .Values.global.wsgi_default_pool_size | default 100 }}

{{- include "util.helpers.valuesToIni" .Values.placement_conf }}
