# CSV 资源系统分阶段任务进度

## 执行规则

- 每次只执行一个小任务。
- 每个任务完成后必须停止，提交改动说明和测试证据。
- 必须得到用户明确同意后，才能执行下一个任务。
- 每个任务都要记录需求、改动范围、测试方式、测试结果、当前状态和验收结论。
- 状态可选值：`未开始`、`进行中`、`待验收`、`已验收`。

## CSV 字段规则

- CSV 第一行为列名。
- `comment_xxx` 列仅作为 CSV 注释，不进入运行时 Resource。
- `xxx_key` 列的值是国际化 key，不是实际展示文案。
- Resource 中保留 `xxx_key` 原值；需要展示时使用 `tr(resource.xxx_key)` 获取当前语言文案。

## 总体进度

| 任务 | 名称 | 状态 | 验收结论 |
| --- | --- | --- | --- |
| Task 0 | 建立任务进度文档 | 已验收 | 用户已验收 |
| Task 1 | CSV 到运行时 Resource 缓存 | 已验收 | 用户已验收 |
| Task 2 | 敌人生成接入 `enemy_config.csv` | 已验收 | 用户已验收 |
| Task 3 | 被动物品替代旧升级奖励 | 待验收 | 2026-05-26 完成，待用户验收 |
| Task 4 | 实现 6 个被动物品效果 | 未开始 | - |
| Task 5 | 敌人死亡掉落拾取物 | 未开始 | - |
| Task 6 | 清理与回归 | 未开始 | - |

## Task 0: 建立任务进度文档

### 需求

- 创建 `docs/csv_resource_rework_progress.md`。
- 写入完整任务列表、执行规则、状态表、验收记录区域。
- 初始状态全部标为 `未开始`，Task 0 完成后标为 `待验收`。
- 记录用户审核补充：`comment_xxx` 不进入 Resource，`xxx_key` 为国际化 key，展示时通过 `tr()` 取实际文案。

### 改动范围

- 新增本文档。

### 测试方式

- 确认文档存在。
- 确认文档包含所有任务、每步验收门禁、测试记录模板。

### 测试结果

- `Test-Path docs\csv_resource_rework_progress.md` 返回 `True`。
- `rg` 已确认文档包含 Task 0 到 Task 6、用户验收门禁、测试方式和验收记录区域。
- 已将 Task 0 审核补充规则写入本文档和 `AGENTS.md`，用于新对话快速恢复上下文。

### 当前状态

- 已验收。

### 验收结论

- 用户已验收 Task 0，同意执行 Task 1。

## Task 1: CSV 到运行时 Resource 缓存

### 需求

- 新增 CSV 读取与构建层，使用首行列名解析。
- 为敌人、被动物品、拾取物新增 Resource 类型。
- 支持 `String`、`float`、`;` 分隔数值数组、资源路径加载。
- 建立 `id -> Resource` 和 `all resources` 查询接口。
- 解析时忽略所有 `comment_xxx` 列。
- Resource 保留 `xxx_key` 字段原始 key 值；展示层通过 `tr()` 获取本地化文案。

### 改动范围

- 新增 `autoload/csv_resource_cache.gd`（CSV 读取、缓存、查询 autoload）。
- 修改 `project.godot`（注册 CSVResourceCache autoload）。
- 新增 `resources/enemy_resource.gd`、`resources/passive_item_resource.gd`、`resources/pickup_item_resource.gd`（三个 Resource 类型）。

### 测试方式

- 用 Godot `--check-only` 检查新增脚本。
- 写临时/测试脚本读取三份 CSV，验证行数、id、关键字段、空字段处理。

### 测试结果

- `--check-only` 通过，零编译错误。运行时输出: Loaded 3 enemy configs, Loaded 6 passive item configs, Loaded 2 pickup item configs。

### 当前状态

- 已验收。

### 验收结论

- 用户已验收。

## Task 2: 敌人生成接入 `enemy_config.csv`

### 需求

- 给 `enemy_config.csv` 增加 `scene` 列。
- `EnemySpawnComponent` 不再用硬编码 `ENEMYS`，改从敌人配置池随机选择。
- 生成敌人时应用配置里的血量/伤害区间；现有敌人行为不重写。
- 注册 CSV 中的敌人场景到 `MultiplayerSpawner`。

### 改动范围

- 修改 `config/enemy_config.csv`，新增 `scene` 列并为每个 enemy id 配置可加载场景。
- 修改 `resources/enemy_resource.gd` 和 `autoload/csv_resource_cache.gd`，让敌人配置加载 `PackedScene`。
- 修改 `components/enemy_spawn_component.gd`，从 `CSVResourceCache` 的敌人配置池随机选择并注册场景到 `MultiplayerSpawner`。
- 修改 `entities/enemy/enemy1/enemy1.gd`、`entities/enemy/enemy2/enemy2.gd`，生成后应用配置血量和伤害区间。
- 修改 `entities/player/player.gd`，允许敌人配置伤害以 `float` 传入玩家受伤逻辑。

### 测试方式

- `--check-only` 检查相关脚本。
- 运行配置加载测试，确认每个 enemy id 都能加载 scene。
- 手动/脚本验证敌人能生成，`enemy_count` 和回合流程正常。

### 测试结果

- `C:\Users\fetasty\bin\godot.exe --headless --path . --check-only --quit` 退出码为 0。
- 输出包含：`[CSV] Loaded 3 enemy configs`、`[CSV] Loaded 6 passive item configs`、`[CSV] Loaded 2 pickup item configs`。
- `stone_poke` 已追加独立 `enemy3.tscn`，不再复用 `enemy1.tscn`。
- 2026-05-22 追加修正：新增 enemy3，使用 `stone-slime-normal` / `stone-slime-attack` 资源；生成后追踪最近玩家，近距离蓄力后切换 attack 资源并打开 1 帧攻击碰撞检测。
- 2026-05-22 追加验证：`C:\Users\fetasty\bin\godot.exe --headless --path . --check-only --quit` 退出码为 0，输出包含 3 enemy configs loaded，未出现脚本解析错误。
- 2026-05-22 MCP 验证：Godot MCP 已确认 Godot 4.6.2 editor 运行且响应；成功打开并读取 `enemy3.tscn`；scene tree 包含 Enemy3 根节点、StateMachine 五个状态、Hitbox/Hurtbox；通过 MCP 直接调用 `set_attack_visual(true/false)` 和 `update_track_target()` 成功。
- 2026-05-22 追加修正：enemy3 攻击状态改为维持 2 秒、期间不可移动；攻击碰撞在整个攻击窗口内开启；Hitbox 增加按 Hurtbox 记录命中的能力，enemy3 每次攻击对同一 Hurtbox 只造成一次伤害。
- 2026-05-22 追加验证：`C:\Users\fetasty\bin\godot.exe --headless --path . --check-only --quit` 退出码为 0；MCP 成功读取更新后的 `enemy3.gd`、`state_attack.gd`、`hitbox_component.gd`、`hurtbox_component.gd`。
- Godot 退出时仍有资源泄漏警告：`ObjectDB instances leaked at exit` / `1 resources still in use at exit`，未出现脚本解析错误。
- 2026-05-25 复核验证：再次执行 `C:\Users\fetasty\bin\godot.exe --headless --path . --check-only --quit`，退出码为 0，项目级检查仍可正常加载 3 个 enemy 配置，说明当前 Task2 链路仍然有效。

### 当前状态

- 已验收。

### 验收结论

- 用户于 2026-05-26 明确说明 Task2 已经验收，同意继续 Task3。

## Task 3: 被动物品替代旧升级奖励

### 需求

- 回合完成奖励池改用 `passive_item_config.csv`。
- UI 继续复用现有奖励选择界面，但绑定新被动物品 Resource。
- 选择结果按 peer 记录为被动物品拥有数量。
- 废弃旧 `available_upgrade_resources` 数据源，不再依赖 `resources/upgrade_resource/*.tres`。

### 改动范围

- 修改 `components/upgrade_component.gd`，移除旧导出奖励池，改为每轮从 `CSVResourceCache.get_all_passives()` 读取被动物品池并随机抽取最多 3 个选项。
- 修改 `components/upgrade_component.tscn`，移除 `resources/upgrade_resource/*.tres` 和 `UpgradeResource` 脚本的场景引用。
- 修改 `ui/game_ui/upgrade_option_item.gd`，让现有奖励选项 UI 绑定 `PassiveItemResource` 并继续通过 `tr(resource.name_key)` / `tr(resource.description_key)` 展示。
- 保留 `UpgradeComponent` / `UpgradeOptionsUI` 旧类名作为现阶段兼容壳；运行时奖励数据源已切换为 `passive_item_config.csv`。

### 测试方式

- `--check-only` 检查脚本。
- 验证每轮展示的奖励来自 passive CSV，且所有物品都有机会出现。
- 验证多人下每个 peer 选择独立记录，选择完成后回合继续。

### 测试结果

- `C:\Users\fetasty\bin\godot.exe --headless --path . --check-only --quit` 退出码为 0。
- 输出包含：`[CSV] Loaded 3 enemy configs`、`[CSV] Loaded 6 passive item configs`、`[CSV] Loaded 2 pickup item configs`。
- 临时验证脚本直接复用 `autoload/csv_resource_cache.gd`，确认 6 个 passive id 都能从 CSV 加载并查询：`basic_damage_up`、`health_limit_up`、`bullet_split`、`attack_speed_up`、`move_speed_up`、`defence_up`。
- 搜索 `components/`、`ui/`、`main.tscn`、`entities/`，未再发现 `available_upgrade_resources`、`resources/upgrade_resource`、`UpgradeResource` 的运行时引用。
- Godot MCP 成功打开 `components/upgrade_component.tscn`，场景树仅保留 `UpgradeComponent` 根节点和 `res://components/upgrade_component.gd` 脚本引用。
- 本次未启动完整多人手动流程；多人选择独立性目前通过 `peer_selected_passives: Dictionary[int, Dictionary]` 的代码路径和项目级编译检查确认，待用户验收时可做实机回合流验证。
- Godot 退出时仍有资源泄漏警告：`ObjectDB instances leaked at exit` / `1 resources still in use at exit`，与 Task2 验证时一致，未出现脚本解析错误。

### 当前状态

- 待验收。

### 验收结论

- 待用户验收；验收后才能继续 Task4。

## Task 4: 实现 6 个被动物品效果

### 需求

- 按 `id` 分发被动效果，不依赖 `effect_type`。
- 实现：基础伤害、血量上限、子弹分裂、攻速、移速、防御。
- 玩家属性读取新被动物品记录，替换旧 `UpgradeComponent.get_peer_upgrade_count` 逻辑。
- 补充玩家受伤、射击、血量上限相关最小接线。

### 改动范围

- 待执行时记录。

### 测试方式

- `--check-only` 检查脚本。
- 分别验证 6 个 id 的效果数值来自 CSV `effect_params`。
- 验证旧三项能力迁移后仍能正常影响玩家。

### 测试结果

- 未开始。

### 当前状态

- 未开始。

### 验收结论

- 未开始。

## Task 5: 敌人死亡掉落拾取物

### 需求

- 新增共享世界 pickup item 场景和脚本。
- 敌人死亡时服务端按 10% 概率生成掉落物。
- 掉落物配置来自 `pickup_item_config.csv`。
- 任意存活玩家触碰后触发效果并同步移除。

### 改动范围

- 待执行时记录。

### 测试方式

- `--check-only` 检查脚本和场景引用。
- 验证掉落物可由 CSV 加载 icon/name/description/effect params。
- 临时提高掉率验证拾取、回血/回满血效果、多人同步移除。
- 恢复 10% 掉率。

### 测试结果

- 未开始。

### 当前状态

- 未开始。

### 验收结论

- 未开始。

## Task 6: 清理与回归

### 需求

- 移除或隔离旧 `upgrade_resource` 依赖。
- 清理命名中的旧 upgrade 概念，必要时保留兼容类名但不再暴露旧资源池。
- 检查翻译提取仍覆盖 CSV 中所有 `_key` 列。
- 补齐文档最终状态和验收记录。

### 改动范围

- 待执行时记录。

### 测试方式

- 全部相关脚本 `--check-only`。
- 搜索确认没有旧奖励池被运行时使用。
- 运行一轮完整流程：开始游戏、敌人生成、回合结束、选择被动物品、下一轮开始、敌人死亡掉落、拾取生效。

### 测试结果

- 未开始。

### 当前状态

- 未开始。

### 验收结论

- 未开始。

## 验收记录

| 任务 | 提交时间 | 测试证据 | 用户验收 |
| --- | --- | --- | --- |
| Task 0 | 2026-05-18 21:30:40 +08:00 | `Test-Path` 返回 `True`；`rg` 命中 Task 0-6、验收门禁、测试方式、验收记录 | 已验收 |
| Task 0 审核补充 | 2026-05-18 21:36:15 +08:00 | 已记录 `comment_xxx` 忽略规则、`xxx_key` + `tr()` 国际化规则，并同步到 `AGENTS.md` | 已验收 |
| Task 1 | 2026-05-19 21:36:59 +08:00 | `--check-only` 0 errors; 3 enemy + 6 passive + 2 pickup loaded | 已验收 |
| Task 2 | 2026-05-20 22:30:04 +08:00 | `--check-only --quit` exit 0; 3 enemy configs loaded; enemy scenes registered from CSV | 已验收 |
| Task 2 追加 enemy3 | 2026-05-22 | 新增 `enemy3.tscn`；`stone_poke` 指向 enemy3；攻击改为 2 秒定身窗口且同一 Hurtbox 每次攻击只受伤一次；`--check-only --quit` exit 0; MCP 打开场景并读取更新后脚本成功 | 已验收 |
| Task 2 复核 | 2026-05-25 | `--check-only --quit` exit 0; 3 enemy + 6 passive + 2 pickup configs loaded | 已验收 |
| Task 3 | 2026-05-26 10:22:11 +08:00 | `--check-only --quit` exit 0; passive CSV 临时验证通过 6 个 id；旧 `.tres` 奖励池运行时引用清理完成；MCP 打开组件场景成功 | 待验收 |
