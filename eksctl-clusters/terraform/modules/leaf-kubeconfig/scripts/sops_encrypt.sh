#!/usr/bin/env bash
set -e

eval "$(jq -r '@sh "CONFIG=\(.config) KMS_ARN=\(.kms_arn)"')"

# curl -s -L "https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux" -o "sops"
# chmod +x sops

content=$(echo "$CONFIG" | sops \
		--encrypt \
		--kms "$KMS_ARN" \
		--input-type=yaml \
		--output-type=yaml \
		/dev/stdin)

jq -n --arg content "$content" '{"content":$content}'
