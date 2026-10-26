-- Ejecutar una vez en el SQL Editor del proyecto ChessErcise.
-- No cambia auth.users ni crea perfiles vacíos al registrar cuentas.
begin;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null check (username ~ '^[A-Za-z0-9_]{3,20}$'),
  birth_date date not null check (birth_date >= date '1900-01-01' and birth_date <= current_date),
  gender text not null check (gender in ('mujer', 'hombre', 'no_binario', 'otro', 'prefiero_no_decir'))
);

create unique index profiles_username_unique on public.profiles (lower(username));

alter table public.profiles enable row level security;
revoke all on public.profiles from anon, authenticated;
grant select, insert, update on public.profiles to authenticated;

create policy profiles_select_own on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);
create policy profiles_update_own on public.profiles
  for update to authenticated using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

commit;
