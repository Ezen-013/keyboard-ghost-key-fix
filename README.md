# 键盘鬼键过滤 · Keyboard Ghost Key Fix

[简体中文](#简体中文) · [English](#english)

## 简体中文

这是一个给 **Windows 桌面**用的 AutoHotkey v2 脚本。适用于能反复重现的**单向串键**：例如只按 `E`，却额外触发反斜杠 `\`；单按反斜杠时又是正常的。脚本按扫描码和时间窗口过滤多余事件，**不修硬件、不解决所有键盘鬼键，也没有配置界面**。如果两颗键互相串、键盘自己乱按、或者多键同时按时有键根本没上报，优先排查硬件。

- 在 Windows 11 x64、AutoHotkey v2.0.28 上核验。随仓库提供 x64/x86 的便携解释器；新环境仍要实测。它作用于当前 Windows 桌面会话的键盘输入，**不区分哪一把键盘**；不支持登录界面或 UAC 安全桌面。
- [`2-fix.ahk`](2-fix.ahk) 保留了原机器的样例规则，默认启用：左 Alt → 右 Ctrl、F2 → F12、数字行 3 → 退格、E → 反斜杠、X → 右 Shift、S → 主键盘回车。箭头右侧是**要过滤的多余键**，不是要输出的字。请先换成你自己的规则，不要直接套用；有意快速连按同一对键也可能被误判。
- 推荐把仓库交给能操作本机文件的 AI Agent，让它先读 [`AGENTS.md`](AGENTS.md)，改好规则并展示变更；用记事本手动试跑，验证无误再决定是否自启。**退出：`Ctrl+Alt+Q` 或右击脚本托盘图标选 Exit。** 日常运行不需要 AI。

### 怎么跟 Agent 说你要改什么

> 读 `AGENTS.md`。不要启动或设置自启，先按下面描述改 `2-fix.ahk` 的 `RULES` 并给我看改动：单按物理键 `E` 会额外出 `\`，单按 `\` 正常。新增这对规则（已有就不用再加）；删除 `F2` 串到 `F12` 的规则；把 `S` 的多余键从主键盘回车改成小键盘回车。其他规则保持不变。我将在记事本里亲自验收。

描述时说清**实际按下的物理键、额外出现的键、单按额外键时的表现**。左右修饰键、主键盘和小键盘要分清。只是某个键坏了想用另一个键代替，属于重映射，不是这个脚本的用途。

## English

An AutoHotkey v2 script for **repeatable, one-way phantom keystrokes on the Windows desktop**. For example, pressing `E` also emits backslash, but pressing backslash on its own works. The script filters the extra event by scan code and timing. It **does not repair hardware, recover missing events, or provide a configuration UI**. It acts on the current desktop session without distinguishing physical keyboards.

Checked on Windows 11 x64 with AutoHotkey v2.0.28. The six active sample rules match the original keyboard: left Alt → right Ctrl, F2 → F12, number-row 3 → Backspace, E → backslash, X → right Shift, S → main Enter. The right-hand side is the unwanted event. Replace the rules before use; intentional rapid key combinations can also be suppressed. Prefer asking a local AI agent to read [`AGENTS.md`](AGENTS.md) and show you the changes before running anything. Test in Notepad; exit with **Ctrl+Alt+Q** or the script's tray menu. No AI is needed at runtime.

Tell the agent which physical key you press, which extra key appears, what happens when the extra key is pressed alone, and exactly which rules to add, remove, or replace. Distinguish left/right modifiers and main/numpad Enter.

## 许可 / License

修复脚本和本项目文档使用 [MIT](LICENSE)。随附的 AutoHotkey v2.0.28 解释器及对应源码保留 GPL v2 或更新版本，以及上游的第三方声明；详见 [`THIRD-PARTY.md`](THIRD-PARTY.md)。这是独立项目，不是 AutoHotkey 官方发行版。

The repair script and project documentation are MIT-licensed. The bundled AutoHotkey runtime and corresponding source keep their upstream GPL v2-or-later and third-party notices. See [`THIRD-PARTY.md`](THIRD-PARTY.md).
