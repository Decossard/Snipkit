# Snipkit

Snipkit is a turn-based messaging app built around intentional, unhurried conversation. You send a message. They reply. One at a time. Media opens once and disappears.

No email. No phone number. No password. We generate everything.

---

## How it works

**Turn-based messaging** — only one person can send at a time. When you send, the other person gets their turn. This slows things down on purpose and removes the anxiety of read receipts and typing indicators.

**Ephemeral media** — photos and voice messages can only be opened once. Once viewed, they're gone.

**Zero-knowledge accounts** — there's no email or password. When you create an account, Snipkit generates a unique username and a 5-word recovery phrase. That phrase is the only way back into your account. We don't store it and we can't recover it.

---

## Tech stack

- **Flutter** — cross-platform UI (mobile + web)
- **Supabase** — auth, database, and realtime subscriptions
- **Riverpod** — state management
- **go_router** — navigation

---

## Features

- One-tap account creation with generated username and recovery phrase
- Username + recovery phrase sign-in (no email, no password)
- Contact requests — add someone by username, they accept or decline
- Turn-based conversations with animated send/wait state
- Realtime message delivery via Supabase subscriptions
- Typing indicator
- Account locking (signs out all devices)
- Blocked contacts management
- Auto-delete timer (UI)

---

## Database schema

Run the following in your Supabase SQL editor to set up the schema:

```sql
-- Profiles (extends auth.users)
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  username text unique not null,
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "Users can read any profile" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Contact requests
create table public.contact_requests (
  id uuid primary key default gen_random_uuid(),
  from_id uuid references public.profiles(id) on delete cascade not null,
  to_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(from_id, to_id)
);
alter table public.contact_requests enable row level security;
create policy "Users can see their own requests" on public.contact_requests
  for select using (auth.uid() = from_id or auth.uid() = to_id);
create policy "Users can send requests" on public.contact_requests
  for insert with check (auth.uid() = from_id);
create policy "Users can delete their own requests" on public.contact_requests
  for delete using (auth.uid() = from_id or auth.uid() = to_id);

-- Contacts (accepted relationships)
create table public.contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  contact_id uuid references public.profiles(id) on delete cascade not null,
  nickname text,
  created_at timestamptz default now(),
  unique(user_id, contact_id)
);
alter table public.contacts enable row level security;
create policy "Users can manage their own contacts" on public.contacts
  for all using (auth.uid() = user_id);

-- Accept request function (creates both sides atomically)
create or replace function accept_contact_request(request_id uuid)
returns void language plpgsql security definer as $$
declare
  req record;
begin
  select * into req from public.contact_requests where id = request_id;
  if req.to_id != auth.uid() then raise exception 'Not authorized'; end if;
  insert into public.contacts(user_id, contact_id) values (req.to_id, req.from_id), (req.from_id, req.to_id)
    on conflict do nothing;
  delete from public.contact_requests where id = request_id;
end;
$$;

-- Conversations
create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  participant_a uuid references public.profiles(id) on delete cascade not null,
  participant_b uuid references public.profiles(id) on delete cascade not null,
  active_turn uuid references public.profiles(id),
  last_message_at timestamptz,
  created_at timestamptz default now(),
  unique(participant_a, participant_b)
);
alter table public.conversations enable row level security;
create policy "Participants can access their conversations" on public.conversations
  for all using (auth.uid() = participant_a or auth.uid() = participant_b);

-- Messages
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  content text,
  type text default 'text',
  opened_at timestamptz,
  created_at timestamptz default now()
);
alter table public.messages enable row level security;
create policy "Participants can access messages" on public.messages
  for all using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
      and (c.participant_a = auth.uid() or c.participant_b = auth.uid())
    )
  );

-- Auto-insert profile on signup
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles(id, username)
  values (new.id, new.raw_user_meta_data->>'username');
  return new;
end;
$$;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();
```

Also disable email confirmation in **Supabase → Authentication → Email → Confirm email**.

---

## Running locally

```bash
flutter pub get
flutter run -d chrome
```

Set your Supabase project URL and anon key in `lib/core/config/app_config.dart`.
