#Requires AutoHotkey v2.0
; ===================================================================
;  键盘故障修复 - 第 2 步（修复）v2
;
;  原理：按下真键前后极短时间内的多余键 = 鬼键 → 整体丢弃；
;        其余情况（含长按自动重复）按原样转发，不改变打字手感。
;
;  本次修订（修两个实测问题）：
;   1) 长按"防误触键"（如退格）现在会连续输出：正常按键的按住、
;      自动重复、松开全程按「连续 down 流 + 收尾 up」转发，等价于
;      系统自动重复；旧版只补发一次按键，长按会丢失重复。
;   2) 鬼键判定改为「按压周期状态机」：一次按压从 down 到 up 是整体，
;      判定后整周期吞/转发；旧版在长按真键时会被重复事件干扰，
;      导致极小概率漏出鬼键。
;
;  适用前提：单向鬼键（按 E 出 E+多余键，单独按多余键只出它自己）。
;
;  退出：Ctrl+Alt+Q
; ===================================================================

; ---------------------------------------------------------------
;  ★★★ 只需要改这一段 ★★★
;
;  real  = 你按下去的键
;  ghost = 跟着冒出来的多余键（要被丢掉的那个）
;
;  可用键名：
;    字母数字  a-z  0-9
;    符号      -  =  [  ]  ;  '  ,  .  /
;    特殊键    backslash(反斜杠)  enter(主键盘回车)  numpadenter(小键盘回车)
;              backspace  tab  space  capslock  menu
;              lshift rshift   lctrl rctrl   lalt ralt
;              f1 ~ f12
;
;  ★ = 表示"和旁边那个是不同键"，别填混：
;      enter  = 主键盘回车      numpadenter = 小键盘回车
;      lalt / ralt              左边 / 右边
; ---------------------------------------------------------------
RULES := [
    { real: "lalt",  ghost: "rctrl" },
    { real: "f2",    ghost: "f12"   },
    { real: "3",     ghost: "backspace" },
    { real: "e",     ghost: "backslash" },
    { real: "x",     ghost: "rshift" },
    { real: "s",     ghost: "enter" },
]
; ---------------------------------------------------------------

WINDOW := 60        ; 鬼键主时间窗（毫秒）：真键按下后这个时间内到达的多余键
                    ; 会被当作鬼键丢弃。仍有漏网→加大；正常按键被误吞→减小。

; ---- 内部参数（一般不用改）----
WINDOW_BACK := 40   ; 鬼键"先到"的覆盖窗（毫秒）。物理上鬼键信号先到时，真键
                    ; 只在几毫秒内跟进；40 足够，调大更保守。
SCAN_MS := 30       ; 状态机扫描间隔（毫秒）
REPEAT_DELAY := 500 ; 长按开始连续输出的延迟（毫秒，近似系统默认）
MAX_HOLD := 10000   ; 单次按压最长保持（毫秒），防御异常情况
DEBUG := false      ; true = 每次判定显示 ToolTip（排查规则是否命中用）

; ---- 以下不用改 ----

#SingleInstance Force

; US ANSI set-1 扫描码（标准 PC 键盘）。E0 扩展键直接使用 0x100 | 基础码。
KEYSC := Map(
    "a",0x1E, "b",0x30, "c",0x2E, "d",0x20, "e",0x12, "f",0x21, "g",0x22, "h",0x23,
    "i",0x17, "j",0x24, "k",0x25, "l",0x26, "m",0x32, "n",0x31, "o",0x18, "p",0x19,
    "q",0x10, "r",0x13, "s",0x1F, "t",0x14, "u",0x16, "v",0x2F, "w",0x11, "x",0x2D,
    "y",0x15, "z",0x2C,
    "0",0x0B, "1",0x02, "2",0x03, "3",0x04, "4",0x05, "5",0x06,
    "6",0x07, "7",0x08, "8",0x09, "9",0x0A,
    "-",0x0C, "=",0x0D, "[",0x1A, "]",0x1B, Chr(0x3B),0x27, "'",0x28,
    ",",0x33, ".",0x34, "/",0x35, "backslash",0x2B,
    "backspace",0x0E, "tab",0x0F, "capslock",0x3A, "space",0x39,
    "enter",0x1C, "numpadenter",0x15C, "menu",0x15D,
    "lshift",0x2A, "rshift",0x136, "lctrl",0x1D, "rctrl",0x11D,
    "lalt",0x38, "ralt",0x138,
    "f1",0x3B, "f2",0x3C, "f3",0x3D, "f4",0x3E, "f5",0x3F, "f6",0x40,
    "f7",0x41, "f8",0x42, "f9",0x43, "f10",0x44, "f11",0x57, "f12",0x58
)

; ---- 配置校验 ----
if (RULES.Length = 0) {
    MsgBox "RULES 是空的，没有要修复的规则。"
    ExitApp
}

msgOf(r) {
    hint := "可用: a-z 0-9 - = , . / backslash enter backspace tab space capslock menu lshift rshift lctrl rctrl lalt ralt f1-f12"
    if (!KEYSC.Has(r.real))
        return "real 键名无效: " r.real "`n" hint
    if (!KEYSC.Has(r.ghost))
        return "ghost 键名无效: " r.ghost "`n" hint
    if (r.real = r.ghost)
        return "real 和 ghost 不能相同: " r.real "`n那会把这个键彻底锁死。"
    return ""
}

ghosts := Map()
for r in RULES {
    if (err := msgOf(r)) {
        MsgBox err
        ExitApp
    }
    if (ghosts.Has(r.ghost)) {
        MsgBox "ghost 键重复: " r.ghost "`n同一个多余键不能挂在两条规则上。"
        ExitApp
    }
    ghosts[r.ghost] := -1
}

; ---- 每个 ghost 键的运行状态 ----
isDown := Map()      ; 物理按住中？
swallow := Map()     ; 本次按压周期判定为「吞」
transmit := Map()    ; 本次按压周期已开始转发输出
downTick := Map()    ; 本周期开始时刻
lastReal := Map()    ; 最近一次对应 real 按下时刻
repeatAt := Map()    ; 转发周期内开始连续输出的时刻
ghostList := []
for g in ghosts {
    isDown[g] := false
    swallow[g] := false
    transmit[g] := false
    downTick[g] := 0
    lastReal[g] := -999999
    repeatAt[g] := 0
    ghostList.Push(g)
}

; ---- 注册 ghost 的 hook hotkey：down / up 全程截获 ----
; 只有 hotkey 能「按周期整体」吞/留；放行由状态机以合成事件完成。
for g in ghosts {
    scName := "sc" Format("{:03X}", KEYSC[g])
    Hotkey("*$" scName, ghostDown.Bind(g))
    Hotkey("*$" scName " up", ghostUp.Bind(g))
}

; ---- InputHook：只监听 real 键（不拦截），用于记录时间窗 ----
ih := InputHook("L0 V")
ih.KeyOpt("{All}", "+N")
ih.OnKeyDown := onKeyDown
ih.Start()

; ---- 状态机心跳 ----
SetTimer(pumpGhosts, SCAN_MS)

txt := ""
for r in RULES
    txt .= r.real " > 丢 " r.ghost "    "
TrayTip("键盘修复已启动", RULES.Length " 条规则`n" txt "`n退出: Ctrl+Alt+Q", 4)

; ---- 函数 ----

; 判断一次按键事件是否就是指定的那个键。
; InputHook 的 SC 对 E0 扩展键使用 0x100 位（例如 RCtrl=sc11D）。
isKey(code, name) {
    global KEYSC
    return code = KEYSC[name]
}

; 以合成事件重放 ghost 键。suffix 为 "" / " down" / " up"。
; {Blind} 保留当时真实按住的修饰键状态（组合键语义不变）。
emitSc(name, suffix := "") {
    global KEYSC
    SendEvent("{Blind}{sc" Format("{:03X}", KEYSC[name]) suffix "}")
}

onKeyDown(ih, vk, sc) {
    global RULES, ghosts, lastReal, WINDOW, DEBUG

    ; 真键按下 → 记录时刻，并给它对应的 ghost 打开丢弃时间窗。
    t := A_TickCount
    for r in RULES {
        if (isKey(sc, r.real)) {
            lastReal[r.ghost] := t
            ghosts[r.ghost] := t + WINDOW
        }
    }
    if (DEBUG)
        ToolTip("[real] sc=" Format("{:03X}", sc))
}

ghostDown(name, *) {
    global isDown, swallow, transmit, downTick, ghosts, DEBUG
    t := A_TickCount

    if (isDown[name]) {
        ; 物理自动重复（或 hotkey 随重复再次触发）：一律吞。
        ; 连续输出由 pumpGhosts 统一生成，避免重复节奏错乱。
        return
    }

    isDown[name] := true
    downTick[name] := t

    if (t <= ghosts[name]) {
        ; 真键刚按下（主窗口内）→ 配对鬼键：整个周期丢弃。
        swallow[name] := true
        transmit[name] := false
        if (DEBUG)
            ToolTip("[丢弃] " name)
        return
    }

    ; 窗口外：先暂存，交给状态机判定（等"真键前后邻域"信息齐全）。
    swallow[name] := false
    transmit[name] := false
    if (DEBUG)
        ToolTip("[暂存] " name)
}

ghostUp(name, *) {
    global isDown, swallow, transmit, downTick, lastReal, WINDOW_BACK, DEBUG

    if (!isDown[name]) {
        ; 孤儿 up（例如脚本启动时该键已被按住）：补发 up 让系统收尾。
        emitSc(name, " up")
        return
    }

    isDown[name] := false

    if (swallow[name]) {
        swallow[name] := false
        transmit[name] := false
        if (DEBUG)
            ToolTip("[吞尾] " name)
        return
    }

    if (transmit[name]) {
        transmit[name] := false
        emitSc(name, " up")
        if (DEBUG)
            ToolTip("[转发尾] " name)
        return
    }

    ; 极短敲击（状态机还没判定就松开了）：
    ; 真键曾在 [按下-40ms, 现在] 出现 → 配对鬼键；否则放行完整按键。
    if (lastReal[name] >= downTick[name] - WINDOW_BACK) {
        if (DEBUG)
            ToolTip("[丢弃] " name)
        return
    }

    emitSc(name)
    if (DEBUG)
        ToolTip("[放行] " name)
}

pumpGhosts() {
    global ghostList, isDown, swallow, transmit, downTick, lastReal, repeatAt, WINDOW_BACK, SCAN_MS, REPEAT_DELAY, MAX_HOLD, DEBUG

    t := A_TickCount
    for name in ghostList {
        if (!isDown[name] || swallow[name])
            continue

        dt := downTick[name]

        ; 防御：up 事件丢失（键盘断连等）→ 强制收尾，避免卡键或持续输出。
        if (t - dt > MAX_HOLD) {
            if (transmit[name]) {
                transmit[name] := false
                emitSc(name, " up")
            }
            swallow[name] := false
            isDown[name] := false
            continue
        }

        if (!transmit[name]) {
            ; 判定延迟：给「鬼键先到」留出真键跟进的时间（SCAN_MS 量级）。
            if (t - dt < SCAN_MS)
                continue

            if (lastReal[name] >= dt - WINDOW_BACK) {
                ; 与真键配对（含鬼键先到情形）→ 整个周期丢弃。
                swallow[name] := true
                if (DEBUG)
                    ToolTip("[判定丢弃] " name)
                continue
            }

            ; 判定为正常按键 → 开始转发（首个 down = 用户看到的第一次输出）。
            transmit[name] := true
            repeatAt[name] := t + REPEAT_DELAY
            emitSc(name, " down")
            continue
        }

        ; 转发进行中：延迟 REPEAT_DELAY 后开始连续输出（等价于系统自动重复），
        ; 此后每个扫描节拍补一个 down，直到物理松开补 up 收尾。
        if (t >= repeatAt[name])
            emitSc(name, " down")
    }
}

^!q::ExitApp
