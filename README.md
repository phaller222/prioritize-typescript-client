# Prioritize TypeScript Client

Official TypeScript/JavaScript client library for the
[Prioritize](https://github.com/phaller222/Prioritize) REST API (`/api/v1`). It is **generated** from
Prioritize's OpenAPI specification with [OpenAPI Generator](https://openapi-generator.tech/)
(`typescript-fetch` generator) — the sources are never hand-written, so the client always matches the
contract of the release it targets.

- **Runtime:** the browser's `fetch` and Node.js 18+ (`fetch` is global there); no runtime dependencies.
- **Client version tracks the API version:** a `1.x` client targets the `1.x` REST API.
- **License:** Apache-2.0 (same as Prioritize).

> **Status:** this client targets **`1.3.0-SNAPSHOT`**, which adds the flat `GET /api/v1/resources`
> list and `GET /api/v1/resources/{id}/values/latest` reads used by the demo dashboard. It is **not yet
> published to npm** — build it locally (see [Building](#building)) or reference it via a local path
> until `1.3.0` is released.

## Installation

Once published:

```bash
npm install prioritize-client
```

Until then, from a local checkout:

```bash
npm install /path/to/prioritize-typescript-client   # after `npm run build`
```

## Usage

Create a `Configuration`, point it at your Prioritize instance, add credentials, then call one of the
per-tag API classes (`UsersApi`, `ProjectsApi`, `TasksApi`, `ResourcesApi`, `TelemetryRulesApi`,
`DocumentsApi`, `SkillsApi`, …). Method names are `<tag><OperationId>`, e.g.
`resourceGetAllResources()`, `resourceGetLatestValues({ id })`.

### Basic auth (default / dev profile)

```ts
import { Configuration, ResourcesApi } from "prioritize-client";

const config = new Configuration({
  basePath: "http://localhost:8080", // the spec paths already carry /api/v1
  username: "admin",
  password: "p@ssword",
});

const resources = new ResourcesApi(config);

// Flat list of every resource the caller may read
const all = await resources.resourceGetAllResources();

// Latest telemetry value per data point of a resource
const values = await resources.resourceGetLatestValues({ id: all[0].id! });
```

### Bearer auth (Keycloak)

```ts
const config = new Configuration({
  basePath: "https://prioritize.example.com",
  accessToken: async () => myKeycloak.token!, // called per request
});
```

## Building

The generated npm package (`package.json`, `tsconfig*.json`, `src/`) is committed. To compile it:

```bash
npm install
npm run build   # tsc -> dist/ (CommonJS) + dist/esm/ (ES modules)
```

## Regenerating from a new API release

The client is spec-first. To retarget it at a newer Prioritize release, drop the released
`docs/openapi.json` in and regenerate — the sources under `src/` are overwritten, the hand-maintained
files (this README, `LICENSE`, `pom.xml`, `generate.sh`, `.gitignore`, `openapi/`) are preserved via
`.openapi-generator-ignore`:

```bash
./generate.sh /path/to/Prioritize/docs/openapi.json
```

This uses the Maven-based OpenAPI Generator harness (`pom.xml`) — the only reason Maven is involved; it
is not part of the published package. Remember to bump `npmVersion` in `pom.xml` to match the API
release before regenerating.
