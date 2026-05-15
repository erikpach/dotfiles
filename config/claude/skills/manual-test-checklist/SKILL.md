---
name: manual-test-checklist
description: Generate a manual browser-test checklist for a finished feature branch and post it to the project issue tracker, split into one checklist per UI surface. Use when the user says "manual test list", "browser tests for this feature", "checklist for QA", "what should I test", "tests for the X branch", or after a feature branch is finished and they want a list of things to click through before merging. Default target tracker is Trello (WODcomp board); also works for GitHub Issues and Linear cards.
---

# Manual Test Checklist

Goal: turn a finished feature branch into a categorized manual-test checklist a human can walk through in the browser before merging. Post it to the matching tracker card as one checklist per category.

The output is what the developer would click through, not what the automated test suite already covers. Pest and feature tests prove the code is correct. This skill captures what a human must verify in the UI: golden paths, locale variants, dark mode, redirects, emails, regressions in adjacent flows.

## Workflow

### 1. Read the branch

Run in parallel:

```
git log main..<branch> --oneline
git diff main..<branch> --stat
```

Then read only files that produce user-visible surfaces. Filament pages, resources, actions, relation managers, Livewire components, Blade views, route-gating middleware, mailables, notifications, console commands users invoke, public routes, registration and auth flows, locale files for new keys.

Skip pure model, migration, factory, test, and PHPDoc files. They introduce no browser-testable behavior on their own. The migration matters only through the UI that exposes it.

If the branch touches `docs/plans/*`, skim those files. They often state intended UX explicitly.

### 2. Identify UI surfaces

Cluster the change into surfaces a tester would visit as one coherent task. Each surface becomes its own checklist on the tracker. Common surfaces:

- A specific page or route (`/reaccept`, `/register`, `/admin/legal-documents`)
- A reusable component (banner, footer, modal, hint slide-over)
- A middleware gate (redirect behavior, grace periods, bypass rules)
- An admin resource (index, view, header action, relation manager, infolist)
- An email or notification (recipient targeting, subject, CTA, locale)
- A console command (idempotency, locale, filtering, scheduling tolerance)
- Smoke or regression (adjacent flows that must keep working: login, logout, password reset, super-admin bypass, unverified-user behavior)

No fixed taxonomy. Three checklists for a small change, ten for a big one. The split should match how a tester would naturally batch the work.

### 3. Generate items per surface

A good item is:

- **One observable outcome.** "Banner hidden when on /reaccept" is testable with a single visit.
- **Specific.** Includes the URL, the field name, the toast text, the expected redirect target.
- **Verifiable visually or via admin.** "Successful signup creates 2 LegalDocumentConsent rows" is checkable via admin without writing SQL.
- **Free of implementation jargon.** Testers don't care about middleware classes; they care that the redirect happens.

Cover these dimensions where they apply:

- Happy path
- Validation and required-field error states
- Locale variants (EN + CS): content, dates (`isoFormat('LL')`), email subject and body
- Light and dark mode where markdown or callouts render
- Authorization (guest vs. authenticated, role-based, tenant-scoped)
- Redirect behavior and gate-page bypass (no double-prompt loops)
- Idempotency for commands (rerun produces no duplicate side effects)
- Email recipient targeting (verified vs. unverified, role filter, CTA link target)
- Edge cases the plan doc called out
- Regressions in adjacent flows the change could plausibly break

Aim for 3 to 6 items per surface. Fewer is fine when a surface only has one observable thing.

### 4. Find the target card

Default tracker: Trello, WODcomp board (`id 607a98a3975c437c2865e231`). Cards live in lists like `🚧 In Progress`, `📋 Backlog`, `🎯 To Do`.

Strategy:

1. Use `mcp__trello__get_my_cards`, filter by feature name matching the branch (branch `legal` matches card "Legal").
2. If output exceeds the tool budget, the MCP saves it to a file. Grep the JSON for `"name"`.
3. If nothing matches, ask the user for the card URL or ID.

GitHub Issues: `gh issue list --search "<feature name>"`. Linear: ask the user for the card ID.

Confirm the card match with the user before writing anything, especially when ambiguous.

### 5. Post checklists

One Trello checklist per surface category. Don't dump everything into a single mega-checklist; that defeats the split.

Trello:

```
mcp__trello__create_checklist  (once per category, name = category)
mcp__trello__add_checklist_item  (once per item, scoped by cardId + checkListName)
```

Send all `create_checklist` calls in one message (parallel), then all `add_checklist_item` calls in one message. The API handles concurrency, no sleeps or batching needed.

GitHub Issues: post as a single comment with `## Category` headings and `- [ ]` items. Linear: same comment-with-headings pattern unless the user prefers otherwise.

### 6. Flag caveats

After posting, surface anything needing human judgment:

- Items marked "Confirm intended": plausible-either-way behavior (super admin still being gated by the consent middleware, for example). Decide deliberately, don't silently ship.
- Things you couldn't easily test in the browser (background queue dispatches, scheduled commands). Name them so the user knows to run the artisan command or fake the schedule.
- Items requiring data setup (backdating `published_at`, creating an unverified user). Call out the fixture need.

## Anti-patterns

- **Mirroring the automated test suite.** If `tests/Feature/.../FooTest.php` asserts something at HTTP level, don't repeat it as a browser item unless visual rendering is the actual concern.
- **Vague items.** "Test the form" is useless. "Submit registration with terms unchecked, see 'must accept' error" is testable.
- **One giant checklist.** A 40-item flat list is unscannable. Split by surface so the tester can pick up where they left off.
- **Over-asserting on copy.** Don't lock items to exact wording unless the wording itself is the feature. "Success toast appears" beats "Toast says 'Document published successfully (v3)'" (the latter rots when the i18n file changes).
- **Inventing surfaces.** If the branch doesn't change emails, don't add a generic "test all emails" section.

## Example output shape

A feature touching registration, a re-acceptance gate, an admin resource, and a console command produces checklists like:

- Registration (4 items)
- Footer (3)
- Public legal pages (3)
- Athlete re-acceptance gate (4)
- Organizer re-acceptance gate (4)
- Banner edge cases (3)
- Admin Legal Documents resource (5)
- Reminder emails (5)
- Smoke and regression (4)

About 35 items across 9 surfaces. A tester picks one surface, finishes it, checks it off, moves on.
