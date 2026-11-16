#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Arguments, each "Y" or "N": skip failures, terraform validate, terraform fmt, checkov, Trivy
SKIPVALIDATIONFAILURE=$1
tfValidate=$2
tfFormat=$3
tfCheckov=$4
tfTrivy=$5

echo "### VALIDATION Overview ###"
echo "-------------------------"
echo "Skip Validation Errors on Failure : ${SKIPVALIDATIONFAILURE}"
echo "Terraform Validate : ${tfValidate}"
echo "Terraform Format   : ${tfFormat}"
echo "Terraform checkov  : ${tfCheckov}"
echo "Terraform Trivy    : ${tfTrivy}"
echo "------------------------"

# Exit codes of the checks. 0 means the check passed or was turned off.
tfValidateOutput=0
tfFormatOutput=0
tfCheckovOutput=0
tfTrivyOutput=0

if [ "${tfValidate}" = "Y" ]; then
  echo "## VALIDATION : Validating Terraform code ..."
  terraform validate
  tfValidateOutput=$?
fi

if [ "${tfFormat}" = "Y" ]; then
  echo "## VALIDATION : Checking Terraform formatting ..."
  terraform fmt -check -recursive
  tfFormatOutput=$?
fi

if [ "${tfCheckov}" = "Y" ]; then
  echo "## VALIDATION : Running checkov ..."
  checkov -o junitxml --framework terraform -d ./ >checkov.xml
  tfCheckovOutput=$?
fi

if [ "${tfTrivy}" = "Y" ]; then
  echo "## VALIDATION : Running Trivy ..."
  trivy config --severity HIGH,CRITICAL --exit-code 1 \
    --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
    --output trivy-junit.xml ./
  tfTrivyOutput=$?
fi

# The buildspec copies these report files, so make sure they exist when a check was turned off.
[ -f checkov.xml ] || echo '<testsuites/>' >checkov.xml
[ -f trivy-junit.xml ] || echo '<testsuites/>' >trivy-junit.xml

echo "## VALIDATION Summary ##"
echo "------------------------"
echo "Terraform Validate : ${tfValidateOutput}"
echo "Terraform Format   : ${tfFormatOutput}"
echo "Terraform checkov  : ${tfCheckovOutput}"
echo "Terraform Trivy    : ${tfTrivyOutput}"
echo "------------------------"

if [ $((tfValidateOutput + tfFormatOutput + tfCheckovOutput + tfTrivyOutput)) -eq 0 ]; then
  echo "## VALIDATION : Checks Passed!!!"
elif [ "${SKIPVALIDATIONFAILURE}" = "Y" ]; then
  # With SKIPVALIDATIONFAILURE set to Y, failed checks are reported but do not stop the build.
  echo "## VALIDATION : Skipping validation failure checks..."
else
  # When validation checks fail, the build process is halted.
  echo "## ERROR : Validation Failed"
  exit 1
fi
