# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Godot 4.6 Multiplayer Shooter

这是一个使用 Godot 4.6 + GDScript 开发的多人合作射击游戏练习项目。服务端权威架构（server-authoritative），支持在线联机和本地单人游玩。

## 构建与运行

```bash
# 在 Godot 编辑器中直接运行（F5）或：
godot --path .

# 构建专用服务器（Linux x86_64）
godot --headless --export-release "dedicated-server" build/godot-multiplayer-shooter-linux-server-x86_64.x86_64

# 构建 Windows 客户端
godot --headless --export-release "Windows Desktop" build/godot-multiplayer-shooter-win_x86_64.exe

# 运行专用服务器（无 GUI）
godot --path . --server --headless
```

## 技术栈

- **引擎**: Godot 4.6
- **语言**: GDScript
- **渲染**: GL Compatibility + D3D12 (Windows)
- **物理**: Jolt Physics (3D physics engine, 2D 项目仍可用)
- **分辨率**: 640x360 视口, 1280x720 窗口, CanvasItems 拉伸

## 项目架构

### 核心场景树

```
Main (main.tscn / main.gd)
├── MultiplayerSpawner          -- 玩家和敌人的网络生成器
├── EnemySpawnComponent         -- 波次管理 + 敌人生成
│   ├── SpawnTimer              -- 生成间隔定时器
│   └── RoundTimer              -- 每波持续时间定时器
├── LobbyComponent              -- 大厅准备状态管理
├── UpgradeComponent            -- 被动物品选取和属性计算
├── PauseMenu / UI 各子场景     -- 游戏内 UI 层
├── PlayerSpawnMarker           -- 玩家生成位置
├── BackgroundEffect            -- 背景特效
└── GameCamera (Camera2D)       -- 相机（带抖动效果）
```

### 自动加载（Autoload / Singletons）

| 名称 | 路径 | 职责 |
|------|------|------|
| `Tools` | autoload/tools.gd | 工具函数：检测 headless server、获取游戏 peers |
| `GameEvents` | autoload/game_events.gd | 全局事件总线（enemy_died, health_changed 等信号） |
| `Background` | autoload/ | 背景音乐循环 |
| `SoundManager` | autoload/sound_manager.gd | 音效管理（hover/click/hurt/died/round 等） |
| `GameState` | autoload/game_state.gd | 全局游戏状态（game_win 标记） |
| `GameCursor` | autoload/game_cursor.gd | 隐藏系统鼠标，使用自定义 Sprite 光标 |
| `KLogger` | addons/godot-logger-master/ | 结构化日志系统 |
| `CSVResourceCache` | autoload/csv_resource_cache.gd | 运行时 CSV → Resource 缓存 |

### 实体层（entities/）

**Player** (`entities/player/player.gd`)
- CharacterBody2D，输入由 `PlayerInputMultiplayerSynchronizerComponent` 同步
- 被动属性（移速、射速、伤害、血量上限、防御）通过 `UpgradeComponent` 的静态方法计算
- 攻击使用计时器控制射速，Authority 端创建 Bullet
- 死亡/复活通过 RPC 同步可见性和位置

**Bullet** (`entities/bullet/bullet.gd`)
- Node2D，单向直线运动，600px/s
- 单次伤害，击中立即销毁
- Authority 端管理生命周期（计时器 5s 超时）

**Enemy 三类型**:
- **Enemy1 (slime/史莱姆)**: 追踪玩家，蓄力冲撞攻击（Hitbox 触发伤害）
- **Enemy2 (poppy/爆炸气球)**: 追踪玩家，近身爆炸（Area2D 检测玩家 + 直接调用 take_damage）
- **Enemy3 (stone_poke/石刺)**: 追踪玩家，切换攻击纹理，维持 Hitbox 持续伤害判定 2s

所有 Enemy 使用相同状态机：
```
spawn → normal → charge → attack → died
```
- `spawn`: 播放缩放生长动画，完成后切换到 normal
- `normal`: 追踪最近存活玩家，移动到攻击距离后切换 charge
- `charge`: 蓄力提示（警告图标缩放动画），完成后切换 attack
- `attack`: 执行攻击（冲撞/爆炸/持续碰撞），冷却后回到 normal
- `died`: 播放死亡特效，queue_free

### 组件层（components/）

| 组件 | 职责 | 备注 |
|------|------|------|
| `HealthComponent` | 血量管理，信号 health_depleted / health_changed | 仅 Authority 端生效 |
| `HitboxComponent` | 伤害输出，与 Hurtbox 碰撞时注册命中 | 支持单次/每 Hurtbox 单次命中 |
| `HurtboxComponent` | 受击检测，接收 Hitbox 伤害 → HealthComponent | 仅 Authority 端处理 area_entered |
| `FlashSpriteComponent` | 受击闪白效果（shader_parameter/percent） | 使用 Sprite2D 材质参数 |
| `PlayerInputMultiplayerSynchronizerComponent` | 同步输入（移动方向、瞄准方向、攻击按下） | MultiplayerSynchronizer 子类 |
| `PlayerDetectComponent` | Area2D 检测区域内玩家 | Enemy2 用于爆炸范围检测 |
| `LobbyComponent` | 大厅就绪状态管理 | 全准备就绪后发射 all_peers_ready_checked |
| `EnemySpawnComponent` | 波次管理、敌人生成（从 CSV 配置读取） | MAX_ROUND=10 |
| `UpgradeComponent` | 被动物品系统 | 静态公式方法，实例单例模式 |

### 数据层

- **CSV 配置文件**: `config/enemy_config.csv` / `passive_item_config.csv` / `pickup_item_config.csv`
- **运行时加载**: `CSVResourceCache` 在 `_ready()` 时解析 CSV，生成 Resource 对象
  - `EnemyResource`: id, scene, name_key, health_range, damage_range
  - `PassiveItemResource`: id, icon, name_key, description_key, effect_params (Array)
  - `PickupItemResource`: id, icon, name_key, description_key, effect_type
- **CSV 约定**:
  - 首行为列名 header
  - `comment_xxx` 列为注释，不映射到 Resource 字段
  - `xxx_key` 列存本地化 key，UI 使用时调用 `tr()`

### 被动物品系统（UpgradeComponent）

物品效果通过 `UpgradeComponent` 的静态方法计算，各节点直接调用：
- `calc_move_speed(peer_id, base)` → 移速 = base × (1 + param × count)
- `calc_fire_rate(peer_id, base)` → 射速 = base × clamp(1 - param × count, 0.001, 10)
- `calc_bullet_damage(peer_id, base)` → 基础伤害 + 加成 - 分裂减伤
- `calc_health_limit(peer_id, base)` → base + param × count
- `calc_defence(peer_id)` → param^count（param=0.8 表示每级减20%伤害）
- `calc_bullet_count(peer_id)` → 1 + param × count（子弹分裂数）

物品选取流程：Authority 端 shuffle 生成选项 → RPC 发送给各 peer → peer 选择 → RPC 回 Authority 记录 → 检查全选完后发射 upgrade_finished。

### UI 结构（ui/）

| UI 路径 | 功能 |
|---------|------|
| `menu/main_menu` | 主菜单（单人/多人/联机/设置/退出） |
| `multiplayer_menu/multiplayer_menu` | 局域网多人连接设置 |
| `onlinegame_menu/online_game_menu` | 在线联机（连接服务器） |
| `pause_menu/pause_menu` | 暂停菜单 |
| `game_ui/player_health_ui` | 玩家血量条 |
| `game_ui/ready_state_ui` | 就绪状态显示 |
| `game_ui/round_timer_ui` | 波次计时器 |
| `game_ui/upgrade_options_ui` | 升级选项面板（三选一） |
| `game_ui/hurt_notify_ui` | 受伤提示闪烁 |
| `game_ui/player_died_ui` | 死亡提示 |
| `game_ui/round_win_ui` | 波次胜利提示 |
| `game_ui/game_win_ui` | 游戏胜利画面 |
| `game_end/game_end_menu` | 游戏结束菜单 |
| `option_menu/option_menu` | 设置面板 |
| `player_look_select_ui/` | 角色外观选择 |
| `confirm_dialog` | 确认弹窗 |

### 多人架构

- 服务端权威：所有游戏逻辑（受伤、生成、波次管理）在 Authority (peer 1) 上执行
- RPC 同步模式：`@rpc("authority", "call_local", "reliable")` 服务端广播、`@rpc("any_peer", ...)` 客户端请求
- `MultiplayerSpawner` 管理玩家和敌人的网络生成
- `MultiplayerSynchronizer`（PlayerInputMultiplayerSynchronizerComponent）同步玩家输入
- 输入通过 `PlayerInputMultiplayerSynchronizerComponent` → `MultiplayerSynchronizer` 自动复制到 Authority 端
- **严重：物理层碰撞在客户端无法执行时，注意保持一致**

### 全局通用模式

- **状态机** (`scripts/state_machine.gd`): 通用有限状态机，通过子节点 State 自动注册。状态切换：`state_machine.current_state = "state_name"`。信号 `transitioned(next)` 用于状态内部跳转。
- **静态单例模式**: 某些组件（GameCamera, UpgradeComponent）暴露 `static var instance`，方便其他节点直接调用：`GameCamera.shake()` / `UpgradeComponent.calc_move_speed(id, base)`
- **非 headless 检测**: `Tools.is_headless_server()` 区分服务端和客户端逻辑
- **日志**: `KLogger.info()` / `KLogger.error()` 替代 print

## 本地化

- 支持中英文（`translate/en_us.mo`, `translate/zh_cn.mo`）
- 自定义资源翻译插件 `addons/custom_resource_translation/`
- CSV 中 `xxx_key` 字段配合 `tr()` 使用

## 物理层配置

| 层 | 用途 |
|----|------|
| layer_1 | wall（墙体） |
| layer_2 | enemy（敌人身体） |
| layer_3 | enemy_hit（敌人攻击判定） |
| layer_4 | player（玩家身体） |
| layer_9 | bullet（子弹） |

## 活动状态

参考 `AGENTS.md` 查看当前活动的 CSV 资源系统重构进度。
