# Enable Realtime (optional — do in Dashboard, not SQL)

The app uses live streams for topics, posts, and comments. Enable realtime via the UI:

1. **Database** → **Publications** (or **Replication** in older UI)
2. Open publication **`supabase_realtime`**
3. Toggle ON: `topics`, `posts`, `comments`

If you prefer SQL and your project supports it, run **one line at a time** in SQL Editor:

```sql
alter publication supabase_realtime add table public.topics;
```

```sql
alter publication supabase_realtime add table public.posts;
```

```sql
alter publication supabase_realtime add table public.comments;
```

If you get an error on `supabase_realtime`, use the Dashboard method above instead.
