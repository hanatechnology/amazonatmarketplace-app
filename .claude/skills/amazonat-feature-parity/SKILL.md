---
name: amazonat-feature-parity
description: Research an Amazonat feature before building it in the Flutter app — pull the exact API contract from the amazonat-client MCP spec and the shipped behavior from the Next.js web client, then produce a compact parity report. Use before implementing any page, feature, or bug fix in marketplace_app, and whenever asked how the web client handles something.
---

# Amazonat Feature Parity Research

Produces the research a Flutter feature needs **before** any Dart is written: the
exact API contract, and how the nearly-complete web client already behaves.

Output is a **parity report** — a compact brief, not a code dump. The point is to
leave context free for the actual implementation.

---

## When to run

- Before any new page, feature, or flow in `marketplace_app`
- Before fixing a bug where the web client may already handle the case correctly
- When asked "how does the web do X"

Skip only for pure-cosmetic mobile-only changes touching no API and no flow.

---

## Repos

| | Path |
|---|---|
| Mobile (target) | `/Users/mac/Desktop/projects/marketplace_app` |
| Web (reference) | `/Users/mac/Desktop/projects/amazonat-client-portal` |
| API spec | MCP server `amazonat-client` |

Read access to the web repo is granted in `.claude/settings.local.json`
(`additionalDirectories`). If reads there are being denied, that entry is missing —
say so rather than guessing at the web's behavior.

---

## Feature → location map

| Feature | Web module | Web route | Mobile page dir |
|---|---|---|---|
| Auth / OTP | `auth` | `(auth)/login`, `(auth)/verify-otp` | `marketplace/auth` |
| Home / banners | `home`, `banners` | `(main)` | `marketplace/home` |
| Products | `products` | `(main)/products` | `marketplace/product` |
| Categories | `categories` | `(main)/categories` | `marketplace/category` |
| Stores / sellers | `stores` | `(main)/stores` | `marketplace/seller` |
| Cart | `cart` | `(main)/cart` | `marketplace/cart` |
| Checkout / orders | `cart`, `profile` | `(main)/checkout` | `marketplace/orders` |
| Profile / addresses | `profile` | `(main)/profile` | `marketplace/account` |
| Refunds | `refunds` | under `profile` | `marketplace/orders` |
| Notifications | `notifications` | `(main)/notifications` | — |

Web module layout: `pages/`, `components/`, `types/`, `utils/`, `index.ts` barrel.
Cross-cutting pieces live in `src/modules/shared/` — notably
`utils/format.ts`, `utils/validationMessages.ts`, `hooks/useApiFieldErrors.ts`,
`hooks/useCurrentUser.ts`, `components/PhoneInput.tsx`, `components/EmptyState.tsx`.
Translations: `messages/en.json`, `messages/ar.json`.

Mobile naming note: the API and web say **store**; the mobile app says **seller**.
Same entity.

---

## Procedure

### Step 1 — Contract from the MCP spec

Call `mcp__amazonat-client__read_project_oas_tjfq6p` to list paths, then
`mcp__amazonat-client__read_project_oas_ref_resources_tjfq6p` with the `$ref`
values for the endpoints in scope. Request the component schemas in the same call
when a DTO is involved.

Capture per endpoint: method + path, params, request DTO fields with required/optional,
success response shape, **every** documented error code and its meaning, and whether
auth is required.

Do not paste the raw JSON into the report. Summarize.

### Step 2 — Behavior from the web client

Delegate to an `Explore` subagent when the module has more than a couple of files —
this is the whole reason the skill exists. Give it the module path and ask for:

- Page flow and navigation, including guards and redirects
- Every state rendered: loading, empty, error, partial
- Form fields, validation rules, and error message keys
- Pagination / filtering / sorting / search behavior and defaults
- Which API endpoints are called, with what params, and in what order
- i18n keys used (so mobile can reuse the same wording)
- Edge cases handled that are easy to miss

Ask it to return a structured summary with file references — not file contents.

### Step 3 — Check what the mobile app already has

Look under `lib/presentation/pages/marketplace/`,
`lib/presentation/controllers/marketplace/`, `lib/data/repositories/`.
Much is already built. Extending an existing controller usually beats a new one.

### Step 4 — Emit the parity report

```markdown
## Parity Report — <feature>

### Endpoints
- `METHOD /path` — purpose. Params: … Returns: … Errors: 400 …, 401 …, 429 …

### Web behavior
- Flow: …
- States: loading … / empty … / error …
- Validation: …
- Pagination: …
- i18n keys: …

### Already in mobile
- <file> — what exists, what is missing

### Conflicts
- <spec vs web disagreement, and which wins>

### Mobile deviations (intended)
- <native pattern replacing a web pattern, with reason>

### Gaps / blockers
- <needed but absent from the spec — flag, do not invent>
```

Then hand off to `marketplace-getx-development` to build.

---

## Resolution rules

- **Contract → spec wins.** The OAS is backend truth. A field the web sends that the
  spec does not document is a mismatch to flag, not a fact to copy.
- **Flow and behavior → web wins.** It is shipped and tested.
- **Presentation → mobile diverges freely.** Bottom sheets over modals, native
  pickers, pull-to-refresh, infinite scroll over numbered pagination, platform back.
  Match behavior and data, not layout.
- **Missing endpoint → stop and report.** Never invent one. Check first whether the
  local spec snapshot is stale (see CLAUDE.md for the re-export steps).

## Report discipline

Keep it under roughly a page. No TSX, no raw OAS JSON, no Dart in the report —
reference files by path and let the implementation step read what it needs.
