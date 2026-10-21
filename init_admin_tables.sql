-- ============================================================
-- tmsg-admin 管理后台五大模块建表脚本
-- 在 Supabase SQL Editor 中执行一次即可（幂等，可重复执行）
-- 与 fix_rls.sql 同样思路：RLS 全部放行 anon（select/insert/update/delete）
-- ============================================================

-- 1. 管理员账号表（权限管理）
create table if not exists public.admin_accounts(
  id bigint generated always as identity primary key,
  username text unique not null,
  password text not null default 'admin123',
  is_super boolean not null default false,
  perms jsonb not null default '{"equip":false,"gift":false,"boss":false,"perm":false,"activity":false}',
  created_at timestamptz not null default now()
);

-- 2. 菜单配置表
create table if not exists public.admin_menus(
  id bigint generated always as identity primary key,
  menu_key text unique not null,
  name text not null,
  perm_key text not null default '',
  sort int not null default 0,
  enabled boolean not null default true
);

-- 3. 装备配置表（后台配 -> 游戏生成）
create table if not exists public.admin_equips(
  id bigint generated always as identity primary key,
  slot text not null,
  name text not null,
  lvl int not null default 1,
  quality jsonb not null default '["普通"]',
  atk int not null default 0,
  def int not null default 0,
  hp int not null default 0,
  mp int not null default 0,
  crit numeric not null default 0,
  dodge numeric not null default 0,
  star3 boolean not null default false,
  price int not null default 100,
  source_bosses jsonb not null default '[]',
  source_flip boolean not null default false,
  source_egg boolean not null default false,
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

-- 4. 礼包配置表
create table if not exists public.admin_gifts(
  id bigint generated always as identity primary key,
  kind text not null default 'normal',
  name text not null,
  desc text not null default '',
  rewards jsonb not null default '[]',
  p numeric not null default 0,
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

-- 5. BOSS 配置表
create table if not exists public.admin_bosses(
  id bigint generated always as identity primary key,
  bid text unique not null,
  name text not null,
  lvl int not null default 60,
  hp int not null default 100000,
  atk int not null default 1000,
  def int not null default 500,
  exp int not null default 10000,
  silver int not null default 5000,
  map text not null default '',
  respawn int not null default 3600,
  shared boolean not null default false,
  drop jsonb not null default '[]',
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

-- 6. 活动配置表
create table if not exists public.admin_activities(
  id bigint generated always as identity primary key,
  act_id text unique not null,
  name text not null,
  desc text not null default '',
  view text not null default '',
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------- RLS：anon 全部放行（与 fix_rls.sql 思路一致） ----------
alter table public.admin_accounts enable row level security;
alter table public.admin_menus enable row level security;
alter table public.admin_equips enable row level security;
alter table public.admin_gifts enable row level security;
alter table public.admin_bosses enable row level security;
alter table public.admin_activities enable row level security;

do $$
declare t text;
begin
  foreach t in array array['admin_accounts','admin_menus','admin_equips','admin_gifts','admin_bosses','admin_activities'] loop
    execute format('drop policy if exists %I on public.%I', 'p_all_'||t, t);
    execute format('create policy %I on public.%I for all using (true) with check (true)', 'p_all_'||t, t);
  end loop;
end $$;

-- ---------- 种子数据 ----------
insert into public.admin_menus(menu_key,name,perm_key,sort) values
  ('dashboard','仪表盘','',1),
  ('users','用户管理','',2),
  ('sponsor','赞助记录','',3),
  ('items','道具管理','',4),
  ('equip','装备管理','equip',5),
  ('gift','礼包管理','gift',6),
  ('boss','BOSS管理','boss',7),
  ('perm','权限管理','perm',8),
  ('activities','活动管理','activity',9),
  ('announce','公告管理','',10),
  ('chat','聊天监控','',11)
on conflict (menu_key) do nothing;

insert into public.admin_activities(act_id,name,desc,view) values
  ('egg','快乐砸蛋','每次砸蛋消耗10元宝','egg'),
  ('flip','幸运翻牌','翻牌有几率额外获得三国币','flip'),
  ('signin','签到好礼','每日签到领好礼','signin'),
  ('regGift','注册领好礼','新玩家注册好礼','regGift'),
  ('luckyshop','三国币兑换','三国币兑奖商店','luckyshop')
on conflict (act_id) do nothing;

insert into public.admin_gifts(kind,name,desc,rewards,p,enabled) values
  ('vip_daily','每日贵宾礼包','每日贵宾可领取，打开获得丰厚奖励',
   '[{"name":"元宝","kind":"yuanbao","num":288},{"name":"[活]砸蛋锤","kind":"eggToken","num":1},{"name":"[活]翻牌令","kind":"flipToken","num":1},{"name":"大魔石","kind":"dms","num":1},{"name":"大血石","kind":"dxs","num":1}]',
   0, true)
on conflict do nothing;
