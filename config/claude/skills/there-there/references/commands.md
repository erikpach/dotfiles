# Command reference

Complete reference for all `there-there` CLI commands. Every command outputs JSON.

## User & Workspace

### get-me

Get the currently authenticated user and workspace.

```bash
there-there get-me
```

**Parameters:** None

**Response fields:** `user` (id, name, email, avatar_url, timezone), `workspace` (id, name, slug)

---

## Tickets

### list-tickets

List all tickets (paginated).

```bash
there-there list-tickets
```

**Optional parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--filter-status` | string | Filter by status (comma separated): `open`, `closed`, `spam` |
| `--filter-tag-ids` | string | Filter by tag IDs (comma separated) |
| `--filter-channel-ids` | string | Filter by channel IDs (comma separated) |
| `--filter-assigned-to-me` | boolean | Only tickets assigned to the authenticated user |
| `--filter-unassigned` | boolean | Only unassigned tickets |
| `--q` | string | Semantic search query. Uses AI embeddings to find tickets by meaning. Results ordered by relevance. |
| `--filter-search` | string | Full-text keyword search across subjects, messages, and contact info |
| `--filter-assigned-user-id` | integer | Filter by specific assignee user ID |
| `--filter-created-after` | string | Only tickets created on or after this date (ISO 8601, e.g. `2026-01-01`) |
| `--filter-created-before` | string | Only tickets created on or before this date (ISO 8601, e.g. `2026-03-01`) |
| `--sort` | string | Sort field. Prefix with `-` for descending. Allowed: `created_at`, `updated_at`, `last_activity_at` |
| `--per-page` | integer | Items per page (max 100, default 25) |
| `--page` | integer | Page number (default: 1) |

**Response:** Paginated. Each ticket has: `id`, `ulid`, `subject`, `status`, `channel`, `assignee`, `contact`, `tags[]`, `latest_message_preview`, `summary`, `created_at`, `updated_at`

### show-ticket

Get ticket details with messages and activities.

```bash
there-there show-ticket --ticket=ULID
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Response:** Full ticket with `messages[]` and `activities[]`. Each message has: `id`, `ulid`, `type` (inbound/outbound/note), `body_html`, `sender`, `attachments[]`, `is_forward`, `created_at`. Each activity has: `id`, `type`, `user`, `properties`, `description`, `created_at`.

### update-ticket-status

Change a ticket's status.

```bash
there-there update-ticket-status --ticket=ULID --field status=closed
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Required body fields (via `--field`):**

| Field | Type | Values |
|---|---|---|
| `status` | string | `open`, `closed`, `spam` |

### update-ticket-assignee

Assign or unassign a user from a ticket.

```bash
there-there update-ticket-assignee --ticket=ULID --field assignee_id=5
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Body fields (via `--field`):**

| Field | Type | Description |
|---|---|---|
| `assignee_id` | integer/null | User ID to assign, or `null` to unassign |

### update-ticket-team

Assign or unassign a team from a ticket.

```bash
there-there update-ticket-team --ticket=ULID --field team_id=3
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Body fields (via `--field`):**

| Field | Type | Description |
|---|---|---|
| `team_id` | integer/null | Team ID to assign, or `null` to unassign |

### add-tag-to-ticket

Add a tag to a ticket.

```bash
there-there add-tag-to-ticket --ticket=ULID --tag=TAG_ULID
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |
| `--tag` | string | Tag ULID |

### remove-tag-from-ticket

Remove a tag from a ticket.

```bash
there-there remove-tag-from-ticket --ticket=ULID --tag=TAG_ULID
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |
| `--tag` | string | Tag ULID |

### list-ticket-activities

List activities for a ticket (paginated).

```bash
there-there list-ticket-activities --ticket=ULID
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Optional parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--page` | integer | Page number (default: 1) |

---

## Messages

### reply-to-ticket

Send a reply to a ticket.

```bash
there-there reply-to-ticket --ticket=ULID --field body="<p>Your reply</p>"
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Required body fields:**

| Field | Type | Description |
|---|---|---|
| `body` | string | HTML body of the reply |

**Optional body fields:**

| Field | Type | Description |
|---|---|---|
| `to_recipients` | array | Email addresses |
| `cc_recipients` | array | CC email addresses |
| `bcc_recipients` | array | BCC email addresses |

### forward-ticket

Forward a ticket to external recipients.

```bash
there-there forward-ticket --ticket=ULID --field body="<p>FYI</p>" --field to_recipients='["someone@example.com"]'
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Required body fields:**

| Field | Type | Description |
|---|---|---|
| `body` | string | HTML body of the forward |
| `to_recipients` | array | At least one email address |

**Optional body fields:**

| Field | Type | Description |
|---|---|---|
| `cc_recipients` | array | CC email addresses |
| `bcc_recipients` | array | BCC email addresses |
| `forwarded_from_message_id` | integer | ID of the original message being forwarded |

### add-note-to-ticket

Add an internal note to a ticket.

```bash
there-there add-note-to-ticket --ticket=ULID --field body="<p>Internal note</p>"
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--ticket` | string | Ticket ULID |

**Required body fields:**

| Field | Type | Description |
|---|---|---|
| `body` | string | HTML body of the note |

---

## Tags

### list-tags

List all workspace tags.

```bash
there-there list-tags
```

**Parameters:** None

**Response:** Array of tags, each with: `id`, `ulid`, `name`, `color`

---

## Channels

### list-channels

List all workspace channels.

```bash
there-there list-channels
```

**Parameters:** None

**Response:** Array of channels, each with: `id`, `name`, `type`, `color`

---

## Members

### list-members

List all workspace members.

```bash
there-there list-members
```

**Parameters:** None

**Response:** Array of users, each with: `id`, `name`, `email`, `avatar_url`, `timezone`

---

## Contacts

### list-contacts

List contacts (paginated).

```bash
there-there list-contacts
```

**Optional parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--filter-name` | string | Filter by name (partial match) |
| `--filter-email` | string | Filter by email (partial match) |
| `--filter-search` | string | Search by name or email |
| `--sort` | string | Sort field. Prefix with `-` for descending. Allowed: `name`, `created_at`, `last_activity` |
| `--per-page` | integer | Items per page (max 100, default 25) |
| `--page` | integer | Page number (default: 1) |

**Response:** Paginated. Each contact has: `id`, `ulid`, `name`, `email`, `avatar_url`, `ticket_count`, `last_activity_at`, `notes`

### show-contact

Get contact details.

```bash
there-there show-contact --contact=ULID
```

**Required parameters:**

| Parameter | Type | Description |
|---|---|---|
| `--contact` | string | Contact ULID |

**Response:** Contact object with: `id`, `ulid`, `name`, `email`, `avatar_url`, `ticket_count`, `last_activity_at`, `notes`
