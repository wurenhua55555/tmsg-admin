-- 地图管理：admin_locations 建表（仅表+RLS，无种子；执行成功后种子由助手写入）
create table if not exists public.admin_locations(
  id bigint generated always as identity primary key,
  map_name text not null,
  city text not null,
  region text not null default '',
  parent text not null default '',
  name text not null,
  npc_type text not null default '',
  npc_name text not null default '',
  npc_level int not null default 0,
  respawn int not null default 0,
  hp int not null default 0,
  atk int not null default 0,
  def int not null default 0,
  crit numeric not null default 0,
  boss_id text not null default '',
  drop_items jsonb not null default '[]',
  npc_talk text not null default '',
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- 兼容已有表：确保所有列存在（幂等）
alter table public.admin_locations add column if not exists map_name text not null default '';
alter table public.admin_locations add column if not exists city text not null default '';
alter table public.admin_locations add column if not exists region text not null default '';
alter table public.admin_locations add column if not exists parent text not null default '';
alter table public.admin_locations add column if not exists name text not null default '';
alter table public.admin_locations add column if not exists npc_type text not null default '';
alter table public.admin_locations add column if not exists npc_name text not null default '';
alter table public.admin_locations add column if not exists npc_level int not null default 0;
alter table public.admin_locations add column if not exists respawn int not null default 0;
alter table public.admin_locations add column if not exists hp int not null default 0;
alter table public.admin_locations add column if not exists atk int not null default 0;
alter table public.admin_locations add column if not exists def int not null default 0;
alter table public.admin_locations add column if not exists crit numeric not null default 0;
alter table public.admin_locations add column if not exists boss_id text not null default '';
alter table public.admin_locations add column if not exists drop_items jsonb not null default '[]';
alter table public.admin_locations add column if not exists npc_talk text not null default '';
alter table public.admin_locations add column if not exists enabled boolean not null default true;
alter table public.admin_locations add column if not exists updated_at timestamptz not null default now();


alter table public.admin_locations enable row level security;
do $$ begin
  execute format('drop policy if exists %I on public.%I', 'p_all_admin_locations', 'admin_locations');
  execute format('create policy %I on public.%I for all using (true) with check (true)', 'p_all_admin_locations', 'admin_locations');
end $$;
