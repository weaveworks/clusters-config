export KEY_NAME="fluxga-gpg-key"
export KEY_COMMENT="fluxga sops validation gpg key"

gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF


gpg --list-secret-keys "${KEY_NAME}"

#export KEY_FP="0E97C0F5DF2997C667DDFFEC03EA65B409F41C3B"

gpg --export-secret-keys --armor "${KEY_FP}" |
kubectl create secret generic sops-gpg-private-key \
--namespace=flux-system \
--from-file=sops.asc=/dev/stdin

gpg --export --armor "${KEY_FP}" |
kubectl create secret generic sops-gpg-public-key \
--namespace=flux-system \
--from-file=sops.asc=/dev/stdin

gpg --delete-secret-keys "${KEY_FP}"
