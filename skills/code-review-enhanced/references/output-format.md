# Output rendering — Phase 7 templates, Phase 9 summary, Phase 10 scoring

Read this once before emitting the first review output. The always-apply rules (grouping,
numbering, ordering, GitLab blank-line rule, Publish prompt) stay in `SKILL.md`; this file holds
the finding templates, the worked example, and the scoring mechanics.

---

## Phase 7 — finding templates

### `[QUESTION]` preamble

When any `[QUESTION]` is emitted, define it once before the findings block, or the label reads
as a weak finding. Blank line after it, before the first file header:

```
`[QUESTION]` = product-judgment doubt only you can resolve, not a defect. Listed last in each file. Not counted in the totals or the score.

```

### Short form (default)

One line each. Insert a **blank line between consecutive short-form findings** in the same file —
without it GitLab renders them as one merged sentence:

```
<i>.<j>) L<line> [<LABEL>] <issue> → <fix>

<i>.<j+1>) L<line> [<LABEL>] <issue> → <fix>
```

### Expanded form

When the explanation does not fit one line. Hard caps: **≤4 bullets, ≤10 lines total, ≤1 reference.**
Blank line after the headline and blank line before `Ref:` are mandatory:

```
<i>.<j>) L<line> [<LABEL>] <one-line headline>

  - <point>
  - <point>

  ```ts
  // Before
  ...
  // After
  ...
  ```

  Ref: <path:line | doc URL | code-review-skill guide path>
```

`[NITPICK]` is always one line. Never expanded.

### `[QUESTION]` expanded form

The opposite of NITPICK — a one-line question is usually too vague to answer. Structure, in order:

1. What the code now does / what changed
2. Why it is ambiguous — the competing readings
3. The concrete options
4. Why it is a question and not a finding
5. Cross-link to a related finding if the answer changes that finding's severity

Same caps as any expanded finding: ≤4 bullets, ≤1 reference. Soft cap 5 questions per review.

### Worked example (blank lines shown exactly as they must appear when pasted into GitLab)

```
1) src/features/financing/hooks/use-application.ts

  1.1) L34-38 [CRITICAL][LOGIC] Guard flipped: cancelled applications now editable

    - Was `status === 'active'`, now `status !== 'draft'` → 'cancelled' passes
    - `submit-button.tsx:22` renders enabled off this hook → user can submit a cancelled application
    - Parallel guard at `application-list.tsx:88` still uses `=== 'active'` → inconsistent

    ```ts
    // After
    if (status !== 'active') return { editable: false };
    ```

    Ref: src/features/financing/utils/status.ts:14

  1.2) L56  [HARNESS] Missing dep in useEffect → stale `applicationId` closure

    Ref: code-review-skill/reference/react.md#hooks

  1.3) L12  [HARNESS] `any` on payload → `payload: ApplicationResponse`

  1.4) L7   [NITPICK] Arrow fn export → `export default function useApplication()`

  1.5) L44  [QUESTION] Draft applications now skip the fee recalculation — intended?

    - The guard changed from `status === 'active'` to `status !== 'cancelled'`, so 'draft' now enters the branch that skips `recalculateFee()`
    - Two readings: drafts genuinely have no fee yet (skipping is correct), or the fee should be recalculated on every edit and 'draft' was included by accident
    - Options: keep as is, or narrow the guard back to an explicit allowlist of statuses
    - Asked rather than flagged because both readings are internally consistent — only product knows which fee model applies to drafts
```

---

## Phase 9 — summary

Blank line before this line, separating it from the last file's findings:

```
CRITICAL N · LOGIC N · HARNESS N · FE N · NITPICK N — <N> files
```

`[QUESTION]` is excluded from that line. If any were emitted, add a second line, on its own line
with a blank line before it:

```

QUESTION N — <N> files
```

Zero findings → `Clean. No findings.` (still emit the QUESTION line if questions exist,
blank-line separated as above).

---

## Phase 10 — scoring

Score after the summary, **always** — even on `Clean. No findings.` (all dimensions default 10,
final 10.0, EXCELLENT).

**Five dimensions, each 0–10, start at 10 and deduct per finding:**

| Dimension | Fed by |
|---|---|
| Code quality | LOGIC, NITPICK |
| Maintainability | NITPICK, HARNESS (naming/simplicity/structure rules) |
| Best practices | FE, HARNESS (pattern/convention rules) |
| Harness compliance | HARNESS only |
| Security compliance | any finding whose evidence cites `security-review-guide`, `sql-injection-prevention`, `xss-prevention`, or is otherwise auth/input/user-data related — default 10 untouched if none |

A finding can feed more than one dimension (e.g. a HARNESS naming violation dents both
Maintainability and Harness compliance). A dimension fed by zero findings stays at 10.

**Per-finding deduction, applied once per fed dimension:**

| Finding | Deduction |
|---|---|
| `[CRITICAL][*]` | −3 |
| `[LOGIC]` (non-critical) | −1.5 |
| `[HARNESS]` (non-critical) | −1 |
| `[FE]` (non-critical) | −1 |
| `[NITPICK]` | −0.5 |
| `[QUESTION]` | 0 — never deducts from any dimension |

Floor each dimension at 0. Final score = mean of the 5 dimensions, one decimal place.

**Classification:** `0.0–4.9` BAD · `5.0–7.9` GOOD · `8.0–10.0` EXCELLENT

**Output block**, always last. Blank line before `Scoring` (separating it from the summary block
above), and a blank line between every dimension line — each `Label: value` line is a standalone
colon-led paragraph, per the GitLab blank-line rule in `SKILL.md` Phase 7:

```

Scoring

  Code quality:        <n>/10

  Maintainability:      <n>/10

  Best practices:       <n>/10

  Harness compliance:   <n>/10

  Security compliance:  <n>/10

  Final: <n>/10 — <BAD|GOOD|EXCELLENT>
```

If a brief closing remark follows (e.g. a one-sentence fix direction), separate it from the
Scoring block with a blank line. If that remark itself opens with a label (`Fix direction: ...`),
the label and its sentence form their own standalone paragraph — never glued to the Scoring block.
