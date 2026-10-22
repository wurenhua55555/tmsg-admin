-- ============================================================
-- 商城管理建表（admin_shop_items）：在 Supabase SQL Editor 执行一次即可（幂等）
-- 执行后告知助手，助手会自动同步游戏当前商城全部商品数据并验证
-- ============================================================
create table if not exists public.admin_shop_items(
  id bigint generated always as identity primary key,
  item_key text unique not null,
  item_type text not null default '其他',
  cat text not null default '其他',
  name text not null,
  qty int not null default 1,
  price int not null default 0,
  price_yb int not null default 0,
  promo boolean not null default false,
  enabled boolean not null default true,
  sort int not null default 0,
  created_at timestamptz not null default now()
);
alter table public.admin_shop_items enable row level security;
do $$ begin
  execute format('drop policy if exists %I on public.%I', 'p_all_admin_shop_items', 'admin_shop_items');
  execute format('create policy %I on public.%I for all using (true) with check (true)', 'p_all_admin_shop_items', 'admin_shop_items');
end $$;
