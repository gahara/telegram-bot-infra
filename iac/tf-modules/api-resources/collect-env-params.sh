#!/bin/sh
# https://support.hashicorp.com/hc/en-us/articles/4547786359571-Reading-and-using-environment-variables-in-Terraform-runs

# The console out is exported as a map in terraform.
jq -n env