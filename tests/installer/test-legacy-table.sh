#!/usr/bin/env bash
# The migrate-harness legacy table lists every path a supported release
# (harness-v0.1.11 onward, decision 0034) installed and the current core does
# not, with the hash of each release's copy. Rebuild that set from the release
# tags and compare it with the table in both directions.
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$root"
first_supported=0.1.11

fail() {
  printf 'legacy table check failed: %s\n' "$*" >&2
  exit 1
}

manifest_entries() {
  git show "$1:scripts/harness-install-files.txt" |
    sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d'
}

current=$(manifest_entries HEAD | awk '{ print $1 }' | LC_ALL=C sort -u)
tags=$(git tag -l 'harness-v*' | sed 's/^harness-v//' | LC_ALL=C sort -V |
  awk -v first="$first_supported" '
    function cmp(a, b,   x, y, i) {
      split(a, x, "."); split(b, y, ".")
      for (i = 1; i <= 3; i++) if (x[i] + 0 != y[i] + 0) return x[i] + 0 < y[i] + 0 ? -1 : 1
      return 0
    }
    cmp($0, first) >= 0 { print "harness-v" $0 }')
[[ -n "$tags" ]] || fail "no harness-v release tag at or after $first_supported; fetch tags"

expected=""
for tag in $tags; do
  while read -r destination _ source; do
    grep -Fxq "$destination" <<<"$current" && continue
    source="${source:-$destination}"
    [[ "$source" != compose:* ]] || fail "$tag dropped composed path $destination; extend this check"
    hash=$(git show "$tag:$source" | tr -d '\r' | sha256sum | awk '{ print $1 }')
    expected+="$destination $hash"$'\n'
  done < <(manifest_entries "$tag")
done
expected=$(printf '%s' "$expected" | LC_ALL=C sort -u)

actual=$(python3 .agents/skills/migrate-harness/scripts/find_legacy.py --print-table |
  python3 -c 'import json, sys
for path, hashes in json.load(sys.stdin).items():
    for value in hashes:
        print(path, value)' | LC_ALL=C sort -u)

table_errors() {
  [[ "$expected" == "$1" ]] && return 0
  diff <(printf '%s\n' "$expected") <(printf '%s\n' "$1") || true
}

errors=$(table_errors "$actual")
[[ -z "$errors" ]] ||
  fail "find_legacy.py LEGACY_FILES differs from the release tags (<: tags, >: table); update the table
$errors"

# Negative proof: a table missing one release copy, or listing an extra one,
# is reported.
[[ -n "$(table_errors "$(printf '%s\n' "$actual" | sed '1d')")" ]] || fail "missed a dropped table entry"
[[ -n "$(table_errors "$(printf '%s\nx/extra.md 00\n' "$actual")")" ]] || fail "missed an extra table entry"

echo "legacy table matches $(wc -w <<<"$tags") supported release tags"
