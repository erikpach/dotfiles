# Workflows

Detailed workflows for common There There CLI tasks.

## Ticket triage

Systematically work through open tickets, review them, and take action.

### Step 1: Get an overview

```bash
# List open tickets, most recently updated first
there-there list-tickets --filter-status=open --sort=-updated_at --per-page=30
```

Present results as a table: subject, status, channel, assignee, tags, last message preview, updated at.

### Step 2: Categorize tickets

Group tickets by:
- **Channel** (email, widget, API) to understand where requests come from
- **Unassigned** tickets that need someone to pick them up
- **Tags** to identify common topics or priorities

### Step 3: Review each ticket

For each ticket that needs attention:

```bash
# View the full ticket with messages
there-there show-ticket --ticket=ULID
```

Read the messages to understand the customer's issue. Check the activities to see what actions have already been taken.

### Step 4: Take action

| Situation | Action |
|---|---|
| Can answer immediately | `there-there reply-to-ticket --ticket=ULID --field body="<p>Your reply</p>"` |
| Needs someone else | `there-there update-ticket-assignee --ticket=ULID --field assignee_id=USER_ID` |
| Issue is resolved | `there-there update-ticket-status --ticket=ULID --field status=closed` |
| Needs internal discussion | `there-there add-note-to-ticket --ticket=ULID --field body="<p>Note for team</p>"` |
| Should be tagged | `there-there add-tag-to-ticket --ticket=ULID --tag=TAG_ULID` |
| Is spam | `there-there update-ticket-status --ticket=ULID --field status=spam` |

### Step 5: Paginate through remaining tickets

```bash
# Next page
there-there list-tickets --filter-status=open --sort=-updated_at --page=2 --per-page=30
```

Repeat until all pages are triaged. Use `meta.last_page` from the response to know when you're done.

---

## Search tickets

### Semantic search (AI-powered)

Find tickets by meaning, not just keywords. Useful for finding tickets about a topic even when exact words differ.

```bash
# Find tickets about refunds
there-there list-tickets --q="how do I get a refund"

# Find billing-related open tickets
there-there list-tickets --q="billing problem" --filter-status=open

# Find recent tickets about a topic
there-there list-tickets --q="password reset" --filter-created-after=2026-01-01
```

Semantic search requires AI to be enabled for the workspace. Results are ordered by relevance.

### Full-text keyword search

Search for exact keywords across ticket subjects, messages, and contact info.

```bash
# Search by keyword
there-there list-tickets --filter-search="refund"

# Search by email
there-there list-tickets --filter-search="john@example.com" --filter-status=open
```

### Filter by date range

```bash
# Tickets from January 2026
there-there list-tickets --filter-created-after=2026-01-01 --filter-created-before=2026-02-01

# Recent tickets
there-there list-tickets --filter-created-after=2026-03-01 --filter-status=open
```

### Filter by specific assignee

```bash
# List workspace members to find user IDs
there-there list-members

# Filter by assignee
there-there list-tickets --filter-assigned-user-id=5
```

---

## Respond to a ticket

### Step 1: View the ticket

```bash
there-there show-ticket --ticket=ULID
```

Read all messages to understand the full conversation history.

### Step 2: Reply

```bash
there-there reply-to-ticket --ticket=ULID --field body="<p>Your reply HTML here</p>"
```

For replies with CC/BCC:

```bash
there-there reply-to-ticket --ticket=ULID \
  --field body="<p>Reply</p>" \
  --field to_recipients='["customer@example.com"]' \
  --field cc_recipients='["manager@example.com"]'
```

### Step 3: Close if resolved

```bash
there-there update-ticket-status --ticket=ULID --field status=closed
```

---

## Forward a ticket

Forward a ticket to an external party for help or escalation.

```bash
# View the ticket first
there-there show-ticket --ticket=ULID

# Forward with context
there-there forward-ticket --ticket=ULID \
  --field body="<p>Can you help with this customer issue?</p>" \
  --field to_recipients='["expert@partner.com"]'
```

---

## Manage contacts

### Find a contact

```bash
# Search by name or email
there-there list-contacts --filter-search=john

# View contact details
there-there show-contact --contact=ULID
```

### View a contact's tickets

Currently, use the contact's email to search for their tickets or view the contact in the web UI for linked tickets.

---

## Assign and organize

### Assign tickets to team members

```bash
# List workspace members to find user IDs
there-there list-members

# Assign a ticket
there-there update-ticket-assignee --ticket=ULID --field assignee_id=5

# Assign to a team
there-there update-ticket-team --ticket=ULID --field team_id=3
```

### Tag tickets for organization

```bash
# List available tags
there-there list-tags

# Add a tag
there-there add-tag-to-ticket --ticket=ULID --tag=TAG_ULID

# Remove a tag
there-there remove-tag-from-ticket --ticket=ULID --tag=TAG_ULID
```

---

## Daily support routine

A suggested daily workflow:

```bash
# 1. Check unassigned tickets
there-there list-tickets --filter-unassigned=true --sort=-updated_at

# 2. Check your assigned tickets
there-there list-tickets --filter-assigned-to-me=true --filter-status=open

# 3. Review and respond to each
there-there show-ticket --ticket=ULID
there-there reply-to-ticket --ticket=ULID --field body="<p>Reply</p>"

# 4. Close resolved tickets
there-there update-ticket-status --ticket=ULID --field status=closed
```
