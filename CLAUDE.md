# Amazonat Libya — Mobile App (Flutter / GetX)

Customer-facing mobile client for the Amazonat Libya marketplace. Companion to the
Next.js web client, which is nearly feature-complete and serves as the behavioral reference.

## Project map

| Thing | Where |
|---|---|
| Mobile app (this repo) | `/Users/mac/Desktop/projects/marketplace_app` |
| Web client (reference) | `/Users/mac/Desktop/projects/amazonat-client-portal` |
| API contract | MCP server `amazonat-client` (local OAS snapshot, 34 paths) |
| Build patterns | Skill `marketplace-getx-development` |
| Parity workflow | Skill `amazonat-feature-parity` |

---

## Mandatory workflow — every feature, page, or bug fix

Do NOT open a Dart file first. Research before building, in this order:

### 1. Contract — read the API spec via MCP

Call `mcp__amazonat-client__read_project_oas_tjfq6p` for the path list, then
`mcp__amazonat-client__read_project_oas_ref_resources_tjfq6p` with the specific
`$ref` paths for the endpoints you need.

Extract: exact path, method, query/path params, request DTO, response shape,
every documented error code and its meaning, and whether the endpoint requires
the `clientAccessToken` bearer.

### 2. Parity — read how the web client already does it

Read `/Users/mac/Desktop/projects/amazonat-client-portal/src/modules/<feature>/`.
Every module holds `pages/`, `components/`, `types/`, `utils/`, plus an `index.ts` barrel.
Shared pieces live in `src/modules/shared/`.

Module names map closely to mobile features: `auth`, `products`, `categories`,
`stores` (mobile calls these "sellers"), `cart`, `profile`, `refunds`, `banners`,
`notifications`, `home`.

Extract: screen flow and navigation, loading / empty / error states, form
validation rules, pagination and filter behavior, i18n keys used, and every edge
case the web already handles.

For anything larger than a single small component, delegate this to the
`amazonat-feature-parity` skill rather than reading the TSX inline — web modules
are big and reading them directly burns the context needed for the Dart work.

### 3. Report — surface findings before writing code

State, briefly: the endpoints in play, the web behavior being matched, anything
where spec and web disagree, and anything the web does that the mobile app
should deliberately do differently. Then build.

### 4. Build — follow `marketplace-getx-development`

That skill owns the HOW: entity → model → repository → use case → controller →
page → binding → route. Follow it exactly.

---

## Conflict resolution

- **Contract conflicts → the OAS wins.** It is backend truth. If the web client
  sends a field the spec does not document, trust the spec and flag the mismatch.
- **UX and flow conflicts → the web wins.** It is shipped, tested behavior.
- **Presentation → mobile is free to diverge.** Use native patterns where they
  fit better: bottom sheets instead of modals, native date/image pickers,
  pull-to-refresh, infinite scroll instead of numbered pagination, platform
  back-navigation. Match the *behavior and data*, not the layout.
- If the spec has no endpoint for what the web appears to do, say so and stop —
  do not invent one.

---

## Hard rules

**API**
- Never invent an endpoint, field, or error code. If it is not in the OAS, it does not exist.
- `DioClient` base URL already ends in `/client/api/v1`. Repository paths are
  relative: `'/products'`, never `'/client/api/v1/products'`.
- Response envelope is `{success, message, status, data}` — parse via
  `BaseResponse` / `BaseListResponse` / `BasePaginatedResponse`, never raw maps.
- Auth is a bearer JWT (`clientAccessToken`), 7-day expiry, issued by
  `POST /auth/verify-otp`. Handle 401 by routing to login.

**Localization**
- Every user-facing string goes through `LocaleKeys.<key>.tr`. No raw strings in widgets.
- Add new keys to `lib/core/localization/locale_keys.dart` AND both translation
  files. Reuse the web's i18n keys from `messages/` where the wording matches.
- App is bilingual AR/EN with RTL. Use directional widgets and `EdgeInsetsDirectional`.

**Design system**
- No `Colors.*`, no magic numbers. Use `MarketplaceColors`, `MarketplaceSpacing`,
  `MarketplaceTypography` from `lib/core/theme/`.

**Architecture**
- Extend the base classes in `lib/core/bases/`; do not bypass them.
- Async state is `AppState<T>` — handle all four of initial / loading / success / error.
- One use case per operation. Controllers call use cases, never repositories directly.

**Verification**
- Run `flutter analyze` before reporting a feature done. Zero new warnings.

---

## Keeping the API spec fresh

The MCP server reads a local snapshot at `docs/amazonat-client-api.json`
(gitignored). It does not auto-sync. When the backend changes, re-export from
the Apidog desktop app — project **Amazonat**, module **Amazonat Client API**,
OpenAPI 3.1 / JSON — to that same path, then call
`mcp__amazonat-client__refresh_project_oas_tjfq6p`.

If an endpoint you expect is missing from the spec, suspect a stale snapshot
before assuming the backend lacks it.
