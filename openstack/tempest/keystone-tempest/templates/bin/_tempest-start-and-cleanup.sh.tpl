#!/usr/bin/env bash

set -o pipefail

{{- include "tempest-base.function_start_tempest_tests" . }}

function cleanup_tempest_leftovers() {
  
  echo "Run cleanup"

  export OS_USERNAME=tempestuser1
  export OS_PROJECT_NAME=tempest1
  export OS_TENANT_NAME=tempest1

  for project in $(openstack project list --domain tempest | grep -oP "tempest-\w*[A-Z]+\w*"); do openstack project delete ${project}; done
  for domain in $(openstack domain list | grep -E 'tempest-test_domain' | awk '{ print $2 }'); do openstack domain set --disable ${domain}; openstack domain delete ${domain}; done

  export OS_USERNAME=admin
  export OS_PROJECT_NAME=admin
  export OS_TENANT_NAME=admin
  for service in $(openstack service list | grep -E 'tempest-service' | awk '{ print $2 }'); do openstack service delete ${service}; done
  for region in $(openstack region list | grep -E 'tempest-region' | awk '{ print $2 }'); do openstack region delete ${region}; done

}

{{- include "tempest-base.function_main" . }}

main
