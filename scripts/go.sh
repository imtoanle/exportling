#!/bin/bash -e
set -euo pipefail
IFS=$'\n\t'

echo "Downloading latest go script..."
bash <(curl -fsSL https://raw.githubusercontent.com/jobready/ready-set-go/master/go.sh)