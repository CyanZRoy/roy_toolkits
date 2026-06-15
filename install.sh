#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${ROOT_DIR}/bin"
SHELL_RC="${HOME}/.bashrc"

usage() {
    cat <<'EOF'
install.sh - install rtoolkit command entry points

Usage:
  bash install.sh [--modify-shellrc]

Options:
  --modify-shellrc    Add rtoolkit's bin directory to ~/.bashrc if missing.
  -h, --help          Show this help message.
EOF
}

MODIFY_SHELLRC=0

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --modify-shellrc)
            MODIFY_SHELLRC=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

chmod +x "${BIN_DIR}/rtoolkit"
chmod +x "${BIN_DIR}/merge-fastq"
chmod +x "${ROOT_DIR}/tools/merge-fastq/bin/merge-fastq"

if [[ "${MODIFY_SHELLRC}" -eq 1 ]]; then
    path_line="export PATH=\"${BIN_DIR}:\$PATH\""
    touch "${SHELL_RC}"
    if ! grep -Fqx "${path_line}" "${SHELL_RC}"; then
        printf '\n# rtoolkit\n%s\n' "${path_line}" >> "${SHELL_RC}"
        printf 'Added rtoolkit to %s\n' "${SHELL_RC}"
    else
        printf 'rtoolkit PATH entry already exists in %s\n' "${SHELL_RC}"
    fi
fi

cat <<EOF
rtoolkit installed.

To use it in the current shell:
  export PATH="${BIN_DIR}:\$PATH"

To make that persistent:
  bash install.sh --modify-shellrc

Try:
  rtoolkit list
  rtoolkit merge-fastq -h
  merge-fastq -h
EOF
