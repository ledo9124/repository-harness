#!/usr/bin/env bash
# Decision 0032: installed docs name only installed paths or consumer-owned
# locations. Installs the core, scans every installed Markdown file, and proves
# the check both ways with fixture documents.
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
temp=$(mktemp -d)
trap 'rm -rf "$temp"' EXIT
core="$temp/core"
checker="$temp/check.py"

cat >"$checker" <<'PY'
import fnmatch
import posixpath
import re
import subprocess
import sys
from pathlib import Path

install_root = Path(sys.argv[1])
repository = Path(sys.argv[2])
CHECK = "tests/installer/assert-installed-docs-paths.sh"

# Consumer-owned locations (decision 0032): paths an installed doc may name
# although Harness does not install them. Each pattern is matched against the
# root-relative path, with `<...>` placeholders read as `*`.
CONSUMER_OWNED = [
    # The consumer's own overview and optional Claude entry.
    ("README.md", "the consumer's own README"),
    ("CLAUDE.md", "the consumer's optional Claude Code entry"),
    # Generic structure the core installs only as READMEs; the content is the
    # consumer's.
    ("docs/product/*", "the consumer's product documents"),
    ("docs/decisions/*", "the consumer's decision records"),
    ("docs/plans/active/*", "the consumer's active execution plan"),
    ("docs/plans/completed/*", "the consumer's completed plans"),
    # Created by installing or updating, not shipped in the payload.
    (".harness-core/*", "installer state written by the harness binary"),
    ("scripts/bin/harness", "the binary shim the installer writes"),
]

EXTENSIONS = (".md", ".sh", ".py", ".rs", ".toml", ".yml", ".yaml", ".json",
              ".txt", ".ps1")

tracked = subprocess.run(
    ["git", "-C", str(repository), "ls-files"],
    check=True, capture_output=True, text=True,
).stdout.splitlines()
upstream_files = set(tracked)
upstream_dirs = {
    str(parent)
    for path in tracked
    for parent in Path(path).parents
    if str(parent) != "."
}

installed_files = {
    path.relative_to(install_root).as_posix()
    for path in install_root.rglob("*")
    if path.is_file() and ".harness-core/base/" not in path.as_posix()
}
installed_dirs = {
    str(parent)
    for path in installed_files
    for parent in Path(path).parents
    if str(parent) != "."
}


def installed(path):
    return path in installed_files or path in installed_dirs


def consumer_owned(path):
    return any(
        fnmatch.fnmatchcase(path, re.sub(r"<[^>]*>", "*", pattern))
        for pattern, _reason in CONSUMER_OWNED
    )


def clean(word):
    """The path-like part of a word, or "" when it names no path."""
    token = word.split("#", 1)[0].lstrip("\"'(<").rstrip("\"'),.;:>")
    if "://" in token or token.startswith(("-", "/", "~", "$")):
        return ""
    # Names that are not paths: no separator and not a file name.
    if "/" not in token and not token.endswith(EXTENSIONS):
        return ""
    return token


def candidates(document, token):
    """Root-relative readings of a token: from the repository root, from the
    document's directory, and (inside a skill) from the skill's directory."""
    origins = [posixpath.dirname(document), ""]
    parts = document.split("/")
    if parts[:2] == [".agents", "skills"] and len(parts) > 3:
        origins.append("/".join(parts[:3]))
    found = []
    for origin in origins:
        path = posixpath.normpath(posixpath.join(origin, token))
        if path in (".", "") or path.startswith("..") or path in found:
            continue
        found.append(path)
    return found


def about_upstream(path):
    """True when the path exists in the upstream repository. Illustrative
    paths that name no upstream file (`public/`, `docs/architecture.md` in an
    example) are not references to it and are left alone."""
    return path in upstream_files or path in upstream_dirs


violations = []
for document in sorted(install_root.rglob("*.md")):
    name = document.relative_to(install_root).as_posix()
    if name.startswith(".harness-core/"):
        continue
    in_fence = False
    for number, line in enumerate(document.read_text(errors="replace").splitlines(), 1):
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            words = line.split()
        else:
            spans = re.findall(r"`([^`]+)`", line) + re.findall(r"\]\(([^)\s]+)", line)
            words = [word for span in spans for word in span.split()]
        for word in words:
            token = clean(word)
            if not token:
                continue
            paths = candidates(name, token)
            if not any(about_upstream(path) for path in paths):
                continue
            if any(installed(path) or consumer_owned(path) for path in paths):
                continue
            print(
                f"installed doc {name}:{number} names {token}, which is not "
                "installed and not a consumer-owned location (decision 0032); "
                "install it, rephrase generically, or add it to the "
                f"consumer-owned list in {CHECK}"
            )
            violations.append(token)
sys.exit(1 if violations else 0)
PY

HARNESS_CORE_BINARY="$root/target/debug/harness" "$root/scripts/install-harness.sh" --directory "$core" --yes >/dev/null

# Positive proof: the installed documents pass.
python3 "$checker" "$core" "$root" || {
  echo "installed docs name paths that are not installed (decision 0032)" >&2
  exit 1
}

# Positive proof: consumer-owned and installed paths in a fixture pass.
allowed="$temp/allowed"
cp -R "$core" "$allowed"
cat >>"$allowed/docs/README.md" <<'EOF'

Fixture: `README.md`, `docs/product/billing.md`, `docs/decisions/0001-choice.md`,
`docs/plans/active/work.md`, `docs/templates/decision.md`, `.harness-core/lock`,
`scripts/bin/harness`, and [the workflow](WORKFLOW.md).
EOF
python3 "$checker" "$allowed" "$root" >/dev/null ||
  { echo "allowed fixture paths were rejected" >&2; exit 1; }

# Negative proof: upstream-only paths in an installed doc fail for that reason.
for upstream_path in crates/harness/ docs/ARCHITECTURE.md scripts/validate-premerge.sh; do
  forbidden="$temp/forbidden"
  rm -rf "$forbidden"
  cp -R "$core" "$forbidden"
  printf '\nFixture: see `%s`.\n' "$upstream_path" >>"$forbidden/docs/README.md"
  if output=$(python3 "$checker" "$forbidden" "$root" 2>&1); then
    echo "fixture naming $upstream_path was accepted" >&2
    exit 1
  fi
  expected="installed doc docs/README.md:"
  [[ "$output" == *"$expected"* && "$output" == *"names $upstream_path, which is not installed and not a consumer-owned location (decision 0032)"* ]] || {
    echo "fixture naming $upstream_path failed for another reason: $output" >&2
    exit 1
  }
done

echo "installed docs name only installed or consumer-owned paths (decision 0032)"
