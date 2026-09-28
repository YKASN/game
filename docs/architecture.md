# 项目架构

## 当前体验

《第七次醒来》用于测试文字驱动的阅读流畅度：黑屏开场 → 逐句阅读 → 房间线稿随剧情变化 → 无人物的对话 → 双气泡选择 → 一句分支反馈 → 共同结尾。没有物品点击或绘画解谜。

## 职责

| 位置 | 职责 |
| --- | --- |
| `content/chapters/seventh_awakening.json` | 台词、停顿、表现提示、选项、分支和结尾 |
| `src/narrative/narrative_runner.gd` | 读取内容，推进步骤，接入选项与共同结尾 |
| `src/narrative/narrative_screen.gd` | 逐字呈现、滚动回看、气泡选择、编辑、流程指标 |
| `src/presentation/` | 白色线稿、场景变化和声音 |
| `src/core/` | 封面、阅读页切换与重玩 |
| `scenes/`、`themes/` | Godot 节点和视觉主题 |

`NarrativeRunner` 不直接操作界面。每条剧情数据的 `cue` 由阅读页传给 `PresentationController`，目前可触发房间出现、窗/桌/镜消失、声音出现和灯灭。`pause_ms` 让打字结束后短暂停顿；其余台词由玩家手动推进。

## 试玩观察

试玩时重点观察：玩家何时提前显示整句、在哪些台词停留、是否自然地滚动回看，以及两枚选择气泡能否被立即理解。`user://demo_sessions.jsonl` 保存每次游玩的时间点、总用时、选择与完成状态；它只保存在本机。根据试玩结果再调整文字长度、打字速度、停顿与版面。
