# LoofGodd Blog

Elixir blog with posts, revisions, tags, and roles.

## Setup

1. **Clone & deps**

   ```bash
   git clone <repo> && cd loofgodd_blog
   mix deps.get
   ```

2. **Database**

   - Edit `config/*.exs` for your DB
   - Run `mix ecto.migrate`

3. **Run & Test**

   ```bash
   # server
   mix phx.server
   # list posts
   mix run scripts/read_posts.exs
   # tests
   mix test
   ```

## Core Modules

- **Role**: seeds default role (`id=1`)
- **Post**: posts + revisions + tags via `create_post/3`
- **Tag**: upserts tags with usage count
- **PostTag**: join schema for posts & tags
