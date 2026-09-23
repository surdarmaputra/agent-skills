# Reference-guide lookup table — Phase 3

Used by `code-review-enhanced` Phase 3 ("Reference-guide lookup"). Before finalizing a
HARNESS / FE / LOGIC finding, if the file's language/framework or the issue's topic has a
dedicated guide below, open it, check for the specific pattern / anti-pattern name, and cite it
as evidence or phrasing.

Rules:
- Only open a guide when a finding is **already suspected** — never read these speculatively.
- Fold the finding back into `code-review-enhanced`'s label scheme (HARNESS/FE/LOGIC/NITPICK/QUESTION).
  Never emit `code-review-skill`'s own markers (🔴/🟡/🟢, `[blocking]`/`[nit]`/etc.).
- A guide entry matching the finding is **not** itself evidence — the Phase 4 evidence bar still applies.
- Full paths resolve under `~/.claude/skills/`.

| Trigger | Guide |
|---|---|
| `.tsx`/`.jsx`, hooks, RSC | `code-review-skill/reference/react.md` |
| `.vue` | `code-review-skill/reference/vue.md` |
| Angular (`.ts` + decorators, signals) | `code-review-skill/reference/angular.md` |
| Svelte / SvelteKit | `code-review-skill/reference/svelte.md` |
| `.rs` | `code-review-skill/reference/rust.md` |
| Plain TS (non-FE-specific) | `code-review-skill/reference/typescript.md` |
| `.java` (17/21) | `code-review-skill/reference/java.md` |
| `.java` (8 / javax.*) | `code-review-skill/reference/java8.md` |
| `.php` | `code-review-skill/reference/php.md` |
| `.rb` / Rails | `code-review-skill/reference/ruby.md` |
| `.py` (general) | `code-review-skill/reference/python.md` |
| Django/DRF | `code-review-skill/reference/django.md` |
| FastAPI | `code-review-skill/reference/fastapi.md` |
| `.go` | `code-review-skill/reference/go.md` |
| `.cs` / .NET | `code-review-skill/reference/csharp.md` |
| `.kt` / Android | `code-review-skill/reference/kotlin.md` |
| `.swift` | `code-review-skill/reference/swift.md` |
| NestJS | `code-review-skill/reference/nestjs.md` |
| `.c` | `code-review-skill/reference/c.md` |
| `.cpp`/`.hpp` | `code-review-skill/reference/cpp.md` |
| `.zig` | `code-review-skill/reference/zig.md` |
| `.css`/`.less`/`.scss` | `code-review-skill/reference/css-less-sass.md` |
| Qt/QML | `code-review-skill/reference/qt.md` |
| Cross-cutting: architecture-scale change | `code-review-skill/reference/architecture-review-guide.md` |
| Cross-cutting: perf-sensitive path | `code-review-skill/reference/performance-review-guide.md` |
| Cross-cutting: auth/input/user-data handling | `code-review-skill/reference/security-review-guide.md`, `reference/cross-cutting/sql-injection-prevention.md`, `reference/cross-cutting/xss-prevention.md` |
| Cross-cutting: any language, generic anti-patterns | `code-review-skill/reference/code-quality-universal.md`, `reference/common-bugs-checklist.md` |
| Cross-cutting: loops over DB/API calls | `code-review-skill/reference/cross-cutting/n-plus-one-queries.md` |
| Cross-cutting: try/catch, error propagation | `code-review-skill/reference/cross-cutting/error-handling-principles.md` |
| Cross-cutting: async/goroutine/actor code | `code-review-skill/reference/cross-cutting/async-concurrency-patterns.md` |
