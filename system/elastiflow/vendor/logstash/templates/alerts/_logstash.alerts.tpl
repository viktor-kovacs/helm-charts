groups:
- name: elastiflow-logstash.alerts
  rules:
  - alert: ElastiflowLogstashPodMissing
    expr: {{ .Values.replicas }} - kube_statefulset_status_replicas_ready{statefulset="elastiflow-logstash"}  > 0
    for: 15m
    labels:
      context: logstash
      service: elastiflow
      severity: info
      tier: os
      meta: '{{`{{ $labels.app }}`}} node(s) missing'
    annotations:
      description: '{{`{{ $labels.app }}`}} node(s) in controlplane cluster missing, please check'
      summary: '{{`{{ $labels.app }}`}} node(s) missing'
  - alert: ElastiflowIncreasedPipelineEvents
    expr: rate(logstash_node_pipeline_events_filtered_total{app="elastiflow-logstash"}[10m]) - rate(logstash_node_pipeline_events_filtered_total{app="elastiflow-logstash"}[1h]) > 300
    for: 5m
    labels:
      severity: info
      tier: net
      service: elastiflow
      context: "{{ $labels.component }}"
      meta: "Controller `{{ $labels.controller_revision_hash }}` in region `{{ $labels.region }}` has an increased number of pipeline events."
      playbook: /docs/devops/alert/network/increased_pipeline_events_todo.html
    annotations:
      description: "Controller `{{ $labels.controller_revision_hash }}` in region `{{ $labels.region }}` has an increased number of pipeline events."
      summary: "Controller `{{ $labels.controller_revision_hash }}` in region `{{ $labels.region }}` has an increased number of pipeline events."
