# Agent 部署与改键手册 · Agent deployment guide

本项目只有 `2-fix.ahk` 负责过滤。它没有配置 UI，也不依赖在线服务。下列步骤用于在用户授权的 Windows 桌面上落地，而不是无人值守部署。未经同意，不启动全局键盘钩子，不修改启动项、注册表、防火墙或文件关联，不提权，不终止用户的其他 AHK 脚本。

## 1. 确认故障与规则

1. 向用户确认：按下哪颗**物理键**，系统额外收到哪颗键；单按额外键是否正常；故障是否可以稳定复现。分辨左右修饰键、主键盘/小键盘回车、数字行/小键盘数字。若只有字符信息无法辨别扫描码，让用户在空白记事本用无敏感内容的单键样本确认；不要启动长时间的按键记录，也不要采集密码或发送完整按键历史。
2. 限定为单向、短时间内的额外事件。双向串键、连续自发乱按、正常物理事件丢失、按住一键却没有对应输入，不要声称本脚本可以修好。若需要只屏蔽某一把键盘、不影响另一把，当前实现不适用。
3. 优先只改 `2-fix.ahk` 的 `RULES := [...]`。逐条解释现有规则，从用户确认的清单出发，不默认沿用六条样例。

| 操作 | 在 `RULES` 中怎么改 |
|---|---|
| 新增 | 新加一行 `{ real: "e", ghost: "backslash" },`；`real` 是物理按下的键，`ghost` 是要丢弃的额外键。现有同一对不重复添加。 |
| 删除 | 删除指定的整个对象行，不动其余规则。全部删除后应直接停止/不部署脚本；空数组会提示并退出。 |
| 修改 | 替换目标对象中的字段，例如 `ghost: "enter"` → `ghost: "numpadenter"`，确认不是主键盘回车。 |

键名以脚本 `KEYSC` 为准：用小写，`backslash` 是反斜杠、`/` 是正斜杠；`enter` 和 `numpadenter` 不同。不要把 `lalt`/`ralt`、`lctrl`/`rctrl` 或 `lshift`/`rshift` 混写。不要添加相同的 `real` 和 `ghost`，不要重复 `ghost`，也不要在常规部署中配置 A→B、B→A 或同一键既是其他规则的 ghost 又是 real。不要猜测未列出的扫描码或修改应急退出组合键。若物理布局不同，先确认实际扫描码；不是映射表里有同名字符就代表同一物理键。

默认前向窗口 `WINDOW = 60` ms。若确需调整，先记录原值、一次调一项：偶发漏过才考虑略增；真实快速连按被误吞时考虑略减。`WINDOW_BACK` 是判定时的回看窗参数，实际可识别的 ghost 先到情况还受扫描与松键时刻约束。`SCAN_MS` 会影响放行和长按重复节奏；不需要为常规改键而修改。不要承诺零延迟或与系统重复速度完全一致。

## 2. 准备与无副作用验收

- 使用本仓库的 `AutoHotkey64.exe`（x64）或 `AutoHotkey32.exe`（x86），或已核实可信的 AutoHotkey **v2**。不运行安装器，不改默认关联。Windows ARM64 未经验证。检查解释器版本和 [`THIRD-PARTY.md`](THIRD-PARTY.md) 的 SHA-256 后，再运行仓库内附带的解释器。
- 把脚本和解释器复制到经用户确认的、由本人管理的目录。修改现有配置前先做备份并展示 `RULES` diff。用 UTF-8 保留中文注释。不要覆盖已运行实例的原始文件，也不要通过开机任务直接试跑。
- 在 PowerShell 中将当前目录切到发布副本，核对哈希并做**仅语法校验、不装钩子**的测试。换 x86 时替换可执行文件名。要求退出码为 0；不要把语法通过写成物理键已验证。

```powershell
Get-FileHash -Algorithm SHA256 .\AutoHotkey64.exe
& .\AutoHotkey64.exe /ErrorStdOut=UTF-8 /Validate (Join-Path $PWD '2-fix.ahk')
if ($LASTEXITCODE -ne 0) { throw 'AutoHotkey syntax validation failed' }
```

## 3. 手动试跑、可选自启与回滚

1. 先让用户准备鼠标或备用输入方式、空白记事本，并确认会按 `Ctrl+Alt+Q` 或通过脚本托盘菜单 Exit。查询是否已有同用途脚本；不同路径的副本可能同时运行。确认后让用户退出**那一个**冲突实例，不要按进程名杀掉全部 AutoHotkey 进程。
2. 征得同意后，再以普通用户、交互式会话手动运行。PowerShell 示例（Windows PowerShell 5.1 和 PowerShell 7 均可）：

   ```powershell
   $script = (Resolve-Path .\2-fix.ahk).Path
   $exe = (Resolve-Path .\AutoHotkey64.exe).Path
   $proc = Start-Process -FilePath $exe -ArgumentList ('"' + $script + '"') -PassThru
   $proc.Id
   ```

3. 让用户在空白记事本逐一测试：真实键只输出所需事件；单按 ghost 键仍正常；测试快打、长按、松键、相关修饰组合，以及实际要用的应用。合成输入不能代替故障键盘的物理测试。发现误吞、卡键、正常组合异常就退出，恢复备份或删除对应规则再试；不要为了适配提权应用而把脚本提升为管理员。
4. **只有当用户要求并通过手动验收后**才配置当前用户登录自启。可在 `shell:startup` 建一个清楚命名的快捷方式：目标指向同一可信解释器，参数是所用脚本的绝对路径（作为一个带引号的参数），工作目录为该部署目录。读回快捷方式目标和参数，确认没有重复实例；不要创建管理员任务或全局启动项。
5. 回滚：先用退出键/托盘停止这个脚本；如创建了启动快捷方式，只移除该快捷方式。恢复目标脚本的已知良好备份。若输入仍异常，检查是否有另一个过滤脚本在运行，再以可信备用输入验证硬件。

Report the final rule diff, runtime path/version, validation exit code, whether the user completed physical testing, whether anything starts on login, and the exact rollback action. Do not claim that a passing syntax check proves the hardware problem is fixed.
