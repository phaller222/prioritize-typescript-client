#!/usr/bin/env bash
#
# Regenerate the TypeScript client from openapi/openapi.json.
#
# Usage:
#   ./generate.sh [path-to-released-openapi.json]
#
# If a path is given, it is copied into openapi/openapi.json first. Older
# Prioritize releases emit an "openapi":"3.1.0" header that OpenAPI Generator
# cannot resolve, so this script rewrites it to "3.0.1" (lossless — no 3.1-only
# constructs are used). The 1.3.0+ specs are already emitted as 3.0.1, so this
# becomes a no-op there.
#
# Generated sources under src/ (and package.json, tsconfig.json, docs/) are
# never hand-edited.
set -euo pipefail
cd "$(dirname "$0")"

SPEC="openapi/openapi.json"
if [ "${1:-}" != "" ]; then
  cp "$1" "$SPEC"
fi

# Pin the OpenAPI header to 3.0.1 if the released spec is 3.1.x.
if grep -q '"openapi"[[:space:]]*:[[:space:]]*"3\.1' "$SPEC"; then
  sed -i 's/"openapi"\([[:space:]]*\):\([[:space:]]*\)"3\.1[0-9.]*"/"openapi"\1:\2"3.0.1"/' "$SPEC"
  echo "Pinned openapi header to 3.0.1"
fi

mvn -q generate-sources

# The typescript-fetch generator stamps the repository URL from the OpenAPI
# tooling default; point it at the real repo so the published package links
# back correctly. Idempotent.
if [ -f package.json ]; then
  node -e '
    const fs=require("fs");
    const p=JSON.parse(fs.readFileSync("package.json","utf8"));
    p.repository={type:"git",url:"git+https://github.com/phaller222/prioritize-typescript-client.git"};
    p.homepage="https://github.com/phaller222/prioritize-typescript-client#readme";
    p.author="Peter Haller";
    p.license="Apache-2.0";
    fs.writeFileSync("package.json",JSON.stringify(p,null,2)+"\n");
  '
fi

echo "Done. Generated npm package into the repo root."
echo "Build & publish: npm install && npm run build && npm publish"
