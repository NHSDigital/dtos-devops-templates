#!/bin/bash
set -euo pipefail

# Delegate to the Terraform-specific unit test target
make terraform-test-modules
