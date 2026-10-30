# tmsg-admin（已降级：仅保留数据库结构与托管配置）

## 重要：后台前端已迁出本仓库

管理后台的**唯一真源**是游戏仓库里的：

```
tmsg-game/admin_index.html
```

原因：本仓库原有的 `index.html` 已与游戏端脱节。它仍在用「前端直接 PATCH 存档 + 回读校验」
的旧赠送实现，而线上服务端已改为 `/api/admin_gift` 事务化赠送（`gift_logs` 状态机、一键补发），
两者的装备属性生成公式也已不一致（旧版攻击附加按「配置值×倍率/1.3」算，比游戏端小近十倍）。

继续部署旧文件会导致后台赠送数值错误、并可能与服务端新增的并发保护冲突。
原文件保留在 `archive/legacy_index.html`，仅供查历史，**不要部署**。

## 本仓库仍负责

- `init_*.sql` / `*_seed.sql` / `fix_rls.sql`：Supabase 建表与种子数据
- `vercel.json`：历史托管配置（当前未启用）

## 后台怎么发布

在 `tmsg-game` 仓库里执行：

```bash
./deploy.sh          # 预演
./deploy.sh --yes    # 上传（游戏本体 + 后台）
```
