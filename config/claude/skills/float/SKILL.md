---
name: float
description: >-
  Plan and manage team allocations on Float.com using the Float API. Use when the
  user wants to plan someone on a project, check who is planned where, view
  allocations, create or update allocations, look up people or projects, or
  anything related to Float resource planning. Triggers on phrases like "plan",
  "allocate", "schedule someone on a project", "who is working on", "Float",
  or any reference to team resource planning.
license: MIT
metadata:
  author: spatie
  version: "0.1.0"
---

# Float Resource Planning

Interact with [Float.com](https://float.com) to plan team members on projects via the Float API v3.

## Prerequisites

The Float API key must be set as an environment variable. Check:

```bash
echo $FLOAT_API_KEY
```

If not set, the Account Owner can find the API key in Float under **Team Settings > Integrations**. Ask the user to set it:

```bash
export FLOAT_API_KEY="your-api-key-here"
```

Or add it to their shell profile for persistence.

## API Basics

- **Base URL:** `https://api.float.com/v3`
- **Auth:** Bearer token via `Authorization: Bearer $FLOAT_API_KEY`
- **Format:** JSON (`Accept: application/json`)
- **Dates:** `YYYY-MM-DD` format
- **Pagination:** `page` (default 1), `per-page` (default 50, max 200)

All requests use curl with these headers:

```bash
curl -s "https://api.float.com/v3/ENDPOINT" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

## Core Workflow: Planning Someone on a Project

When the user says something like "Plan Alex on Project X for 3 days" or "Allocate Sarah to Website Redesign for 4 hours/day next week", follow these steps:

### Step 1: Find the person

```bash
curl -s "https://api.float.com/v3/people" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

Search through the results to find the person by name (case-insensitive partial match). The key field is `people_id`.

### Step 2: Find the project

```bash
curl -s "https://api.float.com/v3/projects" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

Search through results to find the project by name (case-insensitive partial match). The key field is `project_id`.

### Step 3: Create the allocation

```bash
curl -s -X POST "https://api.float.com/v3/tasks" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "people_id": PEOPLE_ID,
    "project_id": PROJECT_ID,
    "start_date": "YYYY-MM-DD",
    "end_date": "YYYY-MM-DD",
    "hours": HOURS_PER_DAY
  }'
```

### Interpreting user requests

- **"for 3 days"** means set start_date to the next working day and end_date 3 working days later (skip weekends). Use a reasonable hours value like 8 (full day).
- **"for 4 hours/day next week"** means start_date = next Monday, end_date = next Friday, hours = 4.
- **"this week"** means start_date = today (or next working day), end_date = Friday of this week.
- **"next week"** means start_date = next Monday, end_date = next Friday.
- **"for 2 weeks"** means start_date = next Monday, end_date = Friday two weeks later.
- **"half days"** means hours = 4.
- **"full days"** or no hours specified means hours = 8.
- Always confirm the interpreted dates and hours with the user before creating the allocation.

## Endpoints Reference

### People

```bash
# List all people (paginated)
curl -s "https://api.float.com/v3/people?per-page=200" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"

# Filter by active status
curl -s "https://api.float.com/v3/people?active=1" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"

# Get a specific person
curl -s "https://api.float.com/v3/people/PEOPLE_ID" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

**Key response fields:** `people_id`, `name`, `email`, `job_title`, `role_id`, `department`, `active`, `employee_type`, `work_days_hours`, `tags`

### Projects

```bash
# List all projects
curl -s "https://api.float.com/v3/projects?per-page=200" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"

# Filter by active projects
curl -s "https://api.float.com/v3/projects?active=1" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"

# Get a specific project
curl -s "https://api.float.com/v3/projects/PROJECT_ID" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

**Key response fields:** `project_id`, `name`, `client_id`, `color`, `status`, `active`, `budget_type`, `budget_total`, `start_date`, `end_date`, `tags`, `notes`

### Allocations (called "tasks" in the API)

```bash
# List allocations with filters
curl -s "https://api.float.com/v3/tasks?people_id=ID&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"

# Get a specific allocation
curl -s "https://api.float.com/v3/tasks/TASK_ID" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"

# Create an allocation
curl -s -X POST "https://api.float.com/v3/tasks" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "people_id": 123,
    "project_id": 456,
    "start_date": "2026-03-16",
    "end_date": "2026-03-20",
    "hours": 8
  }'

# Update an allocation
curl -s -X PATCH "https://api.float.com/v3/tasks/TASK_ID" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "hours": 4,
    "end_date": "2026-03-25"
  }'

# Delete an allocation
curl -s -X DELETE "https://api.float.com/v3/tasks/TASK_ID" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

**Create/Update fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `people_id` | integer | Yes (or people_ids) | Person to allocate |
| `people_ids` | array of int | Yes (or people_id) | Multiple people at once |
| `project_id` | integer | Yes | Project to allocate to |
| `start_date` | string | Yes | Start date (YYYY-MM-DD) |
| `end_date` | string | Yes | End date (YYYY-MM-DD) |
| `hours` | number | Yes | Hours per day |
| `start_time` | string | No | Start time (24h format) |
| `phase_id` | integer | No | Phase within project |
| `status` | integer | No | 0=Draft, 1=Tentative, 2=Confirmed, 3=Complete, 4=Canceled |
| `name` | string | No | Task name |
| `task_meta_id` | integer | No | Project task ID (overrides name) |
| `notes` | string | No | Notes on the allocation |
| `repeat_state` | integer | No | Repeat frequency (0=none) |
| `repeat_end_date` | string | No | When repeating ends (YYYY-MM-DD) |

### Time Off

```bash
# List time off entries
curl -s "https://api.float.com/v3/timeoffs?people_id=ID&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

## Common Queries

### "Who is planned this week?"

Fetch allocations for the current week across all people:

```bash
curl -s "https://api.float.com/v3/tasks?start_date=MONDAY&end_date=FRIDAY&per-page=200" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

Then cross-reference `people_id` and `project_id` with cached people/projects data. Present as a table grouped by person.

### "What is Alex working on?"

1. Find Alex's `people_id` from the people list
2. Fetch their allocations:

```bash
curl -s "https://api.float.com/v3/tasks?people_id=ALEX_ID&start_date=TODAY&end_date=FAR_FUTURE&per-page=200" \
  -H "Authorization: Bearer $FLOAT_API_KEY" \
  -H "Accept: application/json"
```

### "Who is available next week?"

1. Get all active people
2. Get all allocations for next week
3. Compare: people without allocations (or with < 8h/day) are available

## Output Guidelines

- Present allocation data as clean tables when listing multiple items
- Always show: person name, project name, dates, hours/day
- When creating allocations, confirm the details before executing
- After creating/updating, show a summary of what was done
- Use relative date descriptions ("next Monday" not just "2026-03-23") alongside the actual dates
