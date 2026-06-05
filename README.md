# Echo

Voice-first discussion app: topics, voice posts (with required subject), and Reddit-style threaded replies (text or voice).

## Stack

- **Flutter** (Android / iOS)
- **Supabase** — Auth, Postgres, Storage (free tier, no card required)
- Voice files stored as `.aac` in Supabase Storage

## Supabase setup

1. Create a project at [supabase.com](https://supabase.com).
2. **Authentication** → **Providers** → enable **Email** (disable confirm email for faster MVP testing).
3. **SQL Editor** → open [`supabase/schema.sql`](supabase/schema.sql), copy **only the SQL** (not the file path), paste, and **Run**.
4. **Database** → **Publications** → `supabase_realtime` → enable `topics`, `posts`, `comments` (see [`supabase/enable-realtime.md`](supabase/enable-realtime.md)).
5. **Storage** → create bucket named `voice` (or change `storageBucket` in [`lib/supabase_config.dart`](lib/supabase_config.dart)).
6. **Storage policies** — authenticated read + insert on the bucket.
7. **Project Settings** → **API** — credentials live in [`lib/supabase_config.dart`](lib/supabase_config.dart).

Your project URL format: `https://<project-ref>.supabase.co` (also visible in the JWT `ref` claim of the anon key).

## Run the app

```bash
flutter pub get
flutter run
```

## Auth note

Users sign in with **username + password** only. Internally: `{username}@<your-project>.supabase.co` via Supabase email auth (users never see the email).

## Data model

| Table | Purpose |
|-------|---------|
| `profiles` | Unique username per user |
| `topics` | Discussion categories |
| `posts` | Voice post under a topic (`audio_path` in Storage) |
| `comments` | Threaded replies (`parent_comment_id` for nesting) |

## Storage paths

```
voice_posts/{userId}/{postId}.aac
voice_comments/{userId}/{commentId}.aac
```
