---
name: there-there
description: >-
  Manage There There helpdesk tickets, contacts, and channels using the
  there-there CLI. Use when the user wants to list, view, reply to, search,
  or manage tickets; assign team members; manage tags; view contacts; or
  interact with there-there.app from the command line.
license: MIT
metadata:
  author: spatie
  version: "0.0.1"
---

# There There CLI

The `there-there` CLI lets you manage [There There](https://there-there.app) helpdesk tickets from the terminal. Every There There API endpoint has a corresponding command.

## Prerequisites

Check that the CLI is installed:

```bash
there-there --version
```

If not installed:

```bash
composer global require spatie/there-there-cli
```

Ensure Composer's global bin directory is in `PATH`:

```bash
composer global config bin-dir --absolute
```

## Authentication

```bash
# Log in (you'll be prompted for your API token)
there-there login

# Log out
there-there logout
```

Get your API token from your workspace settings at https://there-there.app/settings/api-tokens.

If any command returns a 401 error, the token is invalid or expired. Run `there-there login` again.

## Quick command reference

All commands output JSON. See [references/commands.md](references/commands.md) for full parameter details.

### User & workspace

```bash
# Who am I? Returns user and workspace info
there-there get-me
```

### Tickets

```bash
# List all tickets (paginated)
there-there list-tickets

# Filter by status
there-there list-tickets --filter-status=open

# Filter by channel or tags
there-there list-tickets --filter-channel-ids=1 --filter-tag-ids=1,2

# Only my tickets
there-there list-tickets --filter-assigned-to-me=true

# Sort by most recent activity
there-there list-tickets --sort=-updated_at

# View a specific ticket with messages and activities
there-there show-ticket --ticket=01HX9F3K2M...

# Semantic search (AI-powered, finds tickets by meaning)
there-there list-tickets --q="how do I get a refund"

# Full-text keyword search
there-there list-tickets --filter-search="refund"

# Filter by specific assignee
there-there list-tickets --filter-assigned-user-id=5

# Filter by date range
there-there list-tickets --filter-created-after=2026-01-01 --filter-created-before=2026-02-01

# Combine search with filters
there-there list-tickets --q="billing issue" --filter-status=open --filter-created-after=2026-01-01
```

### Ticket actions

```bash
# Change status
there-there update-ticket-status --ticket=ULID --field status=closed

# Assign to a user
there-there update-ticket-assignee --ticket=ULID --field assignee_id=5

# Unassign
there-there update-ticket-assignee --ticket=ULID --field assignee_id=null

# Assign to a team
there-there update-ticket-team --ticket=ULID --field team_id=3

# Add a tag
there-there add-tag-to-ticket --ticket=ULID --tag=TAG_ULID

# Remove a tag
there-there remove-tag-from-ticket --ticket=ULID --tag=TAG_ULID
```

### Messages

```bash
# Reply to a ticket
there-there reply-to-ticket --ticket=ULID --field body="<p>Thanks for reaching out!</p>"

# Forward a ticket
there-there forward-ticket --ticket=ULID --field body="<p>FYI</p>" --field to_recipients='["someone@example.com"]'

# Add an internal note
there-there add-note-to-ticket --ticket=ULID --field body="<p>Internal note here</p>"
```

### Activities

```bash
# List activities for a ticket
there-there list-ticket-activities --ticket=ULID
```

### Tags, channels, members, contacts

```bash
# List workspace tags
there-there list-tags

# List workspace channels
there-there list-channels

# List workspace members
there-there list-members

# List contacts (with search/filter)
there-there list-contacts --filter-search=john

# View a specific contact
there-there show-contact --contact=ULID
```

### Pagination

All list commands support pagination:

```bash
there-there list-tickets --page=2 --per-page=10
```

## Common workflows

### Ticket triage

List open tickets, review them, and take action. See [references/workflows.md](references/workflows.md) for the full triage workflow.

Quick version:

```bash
# 1. List open tickets sorted by most recent
there-there list-tickets --filter-status=open --sort=-updated_at

# 2. View a ticket to read messages
there-there show-ticket --ticket=ULID

# 3. Reply to the customer
there-there reply-to-ticket --ticket=ULID --field body="<p>Your reply here</p>"

# 4. Close resolved tickets
there-there update-ticket-status --ticket=ULID --field status=closed
```

### Searching tickets

The `list-tickets` command supports two types of search plus date and assignee filters:

- **`--q`** (semantic search): Uses AI embeddings to find tickets by meaning, not just keywords. Matches across subjects, summaries, and message content. Results are ordered by relevance. Requires AI to be enabled for the workspace (returns 422 if not). Can be combined with all other filters.
- **`--filter-search`** (full-text search): Keyword search across ticket subjects, messages, and contact info. Faster than semantic search, good for finding exact terms or email addresses.
- **`--filter-assigned-user-id`**: Filter by a specific user ID (use `list-members` to find IDs). Different from `--filter-assigned-to-me` which uses the authenticated user.
- **`--filter-created-after`**: Only return tickets created on or after this date. ISO 8601 format (e.g. `2026-01-01`).
- **`--filter-created-before`**: Only return tickets created on or before this date. ISO 8601 format (e.g. `2026-03-01`).

All filters can be combined. When `--q` is used without an explicit `--sort`, results are ordered by relevance. When `--q` is used with `--sort`, the explicit sort takes precedence.

```bash
# Semantic search for tickets about a topic
there-there list-tickets --q="how do I get a refund"

# Full-text search for a keyword
there-there list-tickets --filter-search="invoice"

# Combine semantic search with filters
there-there list-tickets --q="billing issue" --filter-status=open --filter-created-after=2026-01-01

# Tickets from a specific user in a date range
there-there list-tickets --filter-assigned-user-id=5 --filter-created-after=2026-01-01 --filter-created-before=2026-02-01
```

### Bulk operations

```bash
# Find all unassigned tickets
there-there list-tickets --filter-unassigned=true

# Assign them
there-there update-ticket-assignee --ticket=ULID --field assignee_id=5
```

## Output format

All commands return JSON. When presenting results to the user:

- **Tickets**: Show as a table with columns: subject, status, channel, assignee, tags, last message preview, updated at.
- **Messages**: Show sender, type (inbound/outbound/note), body preview, attachments count, timestamp.
- **Contacts**: Show name, email, ticket count, last activity.
- **Activities**: Show type, user, description, timestamp.
