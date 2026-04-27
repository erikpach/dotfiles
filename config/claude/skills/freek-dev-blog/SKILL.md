---
name: freek-dev-blog
description: Create and schedule link posts on freek.dev blog. Use when asked to publish, post, or share a link on freek.dev. Handles post creation, updating, and scheduling via the blog API.
---

# freek.dev Blog Posts

## API

All post operations use the freek.dev Blog Posts API. No browser automation needed.

### Base URL

`https://freek.dev/api`

### Authentication

Bearer token in the Authorization header.
Token location: `.secrets/blog-freek-dev.md`

```
Authorization: Bearer <token>
```

### Endpoints

**List posts** — `GET /api/posts`

Query parameters (all optional):
- `published` (0 or 1): filter by published status
- `original_content` (0 or 1): filter by original content
- `tag` (string): filter by tag name
- `search` (string): search by title

Returns paginated results.

**Get a post** — `GET /api/posts/{id}`

**Create a post** — `POST /api/posts`

Body (JSON):
- `title` (string, required)
- `text` (string, required, markdown)
- `publish_date` (ISO 8601 date, nullable)
- `published` (boolean, default false)
- `original_content` (boolean, default false)
- `external_url` (URL string, nullable)
- `tags` (array of strings)
- `send_automated_tweet` (boolean, default false)
- `author_twitter_handle` (string, nullable)
- `series_slug` (string, nullable)

Returns 201 with the created post.

**Update a post** — `PUT /api/posts/{id}`

Same fields as create, all optional. Only send fields you want to change.

**Delete a post** — `DELETE /api/posts/{id}`

Returns 204 No Content.

### Response Format

All responses are wrapped in a `data` key:

```json
{
  "data": {
    "id": 1,
    "title": "...",
    "slug": "...",
    "text": "...",
    "html": "...",
    "publish_date": "2026-03-02T14:00:00+00:00",
    "published": true,
    "original_content": false,
    "external_url": null,
    "series_slug": null,
    "author_twitter_handle": null,
    "send_automated_tweet": false,
    "tags": ["laravel", "php"],
    "url": "https://freek.dev/1-post-slug",
    "preview_url": "https://freek.dev/1-post-slug?preview_secret=abc123",
    "created_at": "2026-03-02T12:00:00+00:00",
    "updated_at": "2026-03-02T12:00:00+00:00"
  }
}
```

### API Usage Examples

Create a link post:
```bash
curl -X POST https://freek.dev/api/posts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Article title here",
    "text": "Short summary of the linked content.",
    "external_url": "https://example.com/article",
    "send_automated_tweet": true
  }'
```

Schedule a post (set publish_date + published):
```bash
curl -X PUT https://freek.dev/api/posts/3040 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "publish_date": "2026-03-03T13:30:00+00:00",
    "published": true
  }'
```

Update post text:
```bash
curl -X PUT https://freek.dev/api/posts/3040 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text": "Updated markdown content here."}'
```

## Creating a Link Post

90% of posts are link posts (external content with a summary).

### Steps

1. Create the post via `POST /api/posts` with:
   - `title`: Use the original article title or a clear variant
   - `text`: 2 sentences max summarizing the linked content. No links in the text.
   - `external_url`: The full URL being linked
   - `original_content`: false (it's a link post)
   - `send_automated_tweet`: true
2. Before scheduling, ALWAYS inspect the existing unpublished queue (`GET /api/posts?published=0`) and look at `publish_date` values. Do not assume the next slot is today.
3. Schedule sequentially after the last already-scheduled post, usually one post per day, around 14:30 CET/CEST unless the existing queue clearly follows a different pattern.
4. To schedule, set `publish_date` to the chosen future time. Do NOT set `published: true` (the blog auto-publishes when the date arrives).
5. **Always confirm** by displaying the created title, full summary text, and preview URL back to the user (so Freek can review what was written)

### Link Post Text Guidelines

- Keep it to 2 sentences max
- Summarize what's interesting about the linked content
- No links in the summary text (the external URL field handles linking)
- No code blocks unless essential
- Write in third person ("They've released..." not "I found...")
- **Never use em dashes in summaries or titles.** Use commas, periods, or "and" instead.

## Creating an Original Content Post

For posts written by Freek (package announcements, tutorials, opinions).

### Steps

1. Create the post via `POST /api/posts` with:
   - `title`: The post title
   - `text`: Full markdown content (see write-freek-dev-blogpost skill for writing style)
   - `original_content`: true
   - `send_automated_tweet`: true (usually)
   - `tags`: Relevant tags as array of strings
2. Share the `preview_url` from the response for review
3. Schedule when Freek approves

## Creating a YouTube Video Post

When Freek shares a YouTube link for the blog.

### Steps

1. Get the video ID from the YouTube URL (e.g. `dQw4w9WgXcQ` from `youtube.com/watch?v=dQw4w9WgXcQ`)
2. Get the video title via oembed API: `youtube.com/oembed?url=VIDEO_URL&format=json`
3. Create the post via `POST /api/posts` with:
   - `title`: Use the video title
   - `text`: Summary text followed by a blank line and the YouTube iframe embed:
     ```
     Summary text here.

     <iframe width="560" height="315" src="https://www.youtube.com/embed/VIDEO_ID" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
     ```
   - `external_url`: null (the embed IS the content)
   - `original_content`: false
   - `author_twitter_handle`: Set if known
   - `send_automated_tweet`: true
4. **Always confirm** by displaying the title, full summary text, and preview URL

### YouTube Embed Notes
- If the original URL has a timestamp (`t=24` or `start=24`), add `?start=24` to the embed src
- Use `width="560" height="315"` as standard dimensions

## Creating a Tweet Embed Post

When Freek wants to embed a Twitter/X thread on the blog.

### Steps

1. Gather the tweet IDs from the thread
2. Create the post via `POST /api/posts` with:
   - `title`: Descriptive title (e.g. "A Twitter thread about laravel-permission v7")
   - `text`: Minimal blockquotes with `data-conversation="none"`:
     ```html
     <blockquote class="twitter-tweet" data-conversation="none">
       <a href="https://twitter.com/USERNAME/status/TWEET_ID"></a>
     </blockquote>

     <blockquote class="twitter-tweet" data-conversation="none">
       <a href="https://twitter.com/USERNAME/status/TWEET_ID_2"></a>
     </blockquote>

     <script async src="https://platform.twitter.com/widgets.js"></script>
     ```
   - `external_url`: null
   - `original_content`: true (it's Freek's own content)
   - `author_twitter_handle`: Tweet author (e.g. `freekmurze`)
   - `send_automated_tweet`: false (the tweets already exist)
3. Confirm with the preview URL so Freek can verify the embeds render

### Tweet Embed Notes
- `data-conversation="none"` prevents showing the parent tweet above each reply
- Use ONE `<script>` tag at the end, not per-blockquote
- Twitter's widget.js renders the blockquotes client-side into rich embeds

## Scheduling Convention

Standard scheduling: sequential daily at ~14:30 CET (13:30 UTC in winter, 12:30 UTC in summer).

⚠️ **CRITICAL: NEVER set `published: true` for scheduled posts.** Setting `published: true` publishes IMMEDIATELY and triggers the automated tweet. The blog auto-publishes posts when their `publish_date` arrives.

**To schedule a new post:** Create with `published: false` (or omit, it defaults to false) and set `publish_date` to the desired future date.

**To schedule an existing post:** Update with `published: false` and `publish_date`:
```
PUT /api/posts/{id}
{"published": false, "publish_date": "2026-03-03T13:30:00+00:00"}
```

## Example Link Post

**Title:** SQL performance improvements: automatic detection & regression testing

**Text:**
```
The final part of Oh Dear's series on SQL performance. Mattias introduces phpunit-query-count-assertions, a package that catches N+1 queries, duplicate queries, and missing indexes in your test suite.
```

**External url:** `https://ohdear.app/news-and-updates/...`
