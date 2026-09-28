# 项目架构（Phase 0）

## 目标

这是一款以文字推动的黑白 2D 游戏。玩家点击文字，场景和声音随之变化。当前版本只验证“文字本身是交互对象”：封面 → 短场景 → 点击推进 → 一次视觉与声音反馈 → 结束。

## 边界

| 目录 | 职责 |
| --- | --- |
| `scenes/` | Godot 可编辑场景与节点布局 |
| `src/core/` | 启动和页面切换 |
| `src/narrative/` | 按顺序读取内容并发出当前文字事件 |
| `src/presentation/` | 画面与声音反馈 |
| `src/interaction/` | 给后续交互玩法预留的最小接口 |
| `content/` | 剧情数据，不放在脚本里 |
| `themes/`、`assets/` | 字体、音效和统一主题 |

`Main` 只负责切换封面与叙事场景。`NarrativeRunner` 只负责读取和推进事件，不直接控制场景、音频或画面。叙事场景收到事件后把 `cue` 交给 `Presentation`。后续需要手绘、谜题或物理时，通过 `Interaction` 边界接入；现在没有实现这些系统，也没有引入第三方插件。

## 内容格式

`content/chapters/prologue.json` 的 `steps` 是有序文字事件。每条含 `id`、`text` 和可选 `cue`。当前 cue 只有 `dark`、`reveal_room`、`start_tick`、`stop_tick`、`none`；它们是这段样片的表现指令，不是通用剧情语言。

## 后续里程碑

1. 试玩这段 20–30 秒的样片，确认文字位置、阅读节奏、反馈力度。
2. 根据试玩结果再定义正式 Narrative Runtime 和内容编辑方式。
3. 之后才设计交互框架；物理手绘属于更后的独立原型。
