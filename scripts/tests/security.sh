#!/bin/bash
set -euo pipefail

# Delegate to the Terraform-specific security target
make terraform-security
