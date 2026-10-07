#!/usr/bin/env bash
set -euo pipefail

# Exit successfully only when a changed path can alter the core-maintenance
# binary, its embedded payload, bootstrap contract, or release proof.
# Payload paths come from the one declaration of the installed list: the
# sources named in scripts/harness-install-files.txt.
manifest="$(dirname "${BASH_SOURCE[0]}")/harness-install-files.txt"

payload_sources="$(
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' \
    -e 's/^.*<-[[:space:]]*//' -e 's/^compose://' -e 's/[[:space:]]*$//' "$manifest" |
    sed -e 's/[][\.^$*+?(){}|]/\\&/g' -e 's/$/$/'
)"
[ -n "$payload_sources" ] || {
  echo "no payload sources in $manifest" >&2
  exit 1
}

pattern='^('
pattern+="$(printf '%s\n' "$payload_sources" | paste -sd'|' -)|"
pattern+='crates/harness/|Cargo\.toml$|Cargo\.lock$|'
pattern+='scripts/(harness-install-files\.txt|harness-release-tag)$|'
pattern+='scripts/(install-harness|build-harness-release|harness-release-changed|promote-harness-release-tag|verify-harness-release-assets|verify-harness-release-identity)\.(sh|ps1)$|'
pattern+='\.github/workflows/(harness-release|post-merge-maintenance)\.yml$|'
pattern+='tests/installer/test-install-harness-modes\.(sh|ps1)$|'
pattern+='tests/maintenance/test-harness-release-classification\.sh$'
pattern+=')'
grep -Eq "$pattern"
