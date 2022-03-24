#!/usr/bin/env bash

set -o pipefail

{{- include "tempest-base.function_start_tempest_tests" . }}

function cleanup_tempest_leftovers() {
  
  echo "Run cleanup"
  export OS_USERNAME=admin
  export OS_PROJECT_NAME=admin
  export OS_TENANT_NAME=admin

  for service in $(openstack service list | grep -E 'tempest-service' | awk '{ print $2 }'); do openstack service delete ${service}; done
  for region in $(openstack region list | grep -E 'tempest-region' | awk '{ print $2 }'); do openstack region delete ${region}; done
  # for project in $(openstack project list --domain tempest | grep -oP "tempest-\w*[A-Z]+\S+"); do openstack project delete ${project}; done
  for domain in $(openstack domain list | grep -E 'tempest-test_domain' | awk '{ print $2 }'); do openstack domain set --disable ${domain}; openstack domain delete ${domain}; done
  unset OS_PROJECT_DOMAIN_NAME
  unset OS_PROJECT_NAME
  unset OS_USERNAME
  unset OS_USER_DOMAIN_NAME
  for project in $(openstack project list --domain tempest | grep -oP "tempest-\w*[A-Z]+\S+"); do openstack --os-username=admin --os-user-domain-name=tempest --os-password={{ .Values.tempestAdminPassword | quote }} --os-domain-name=tempest project delete ${project}; done

}

{{- include "tempest-base.function_main" . }}

main
