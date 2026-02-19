#!/bin/bash
set -euo pipefail

# Delegate to the Terraform-specific lint target
make terraform-lint
