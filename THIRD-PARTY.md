# 第三方组件 · Third-party notices

本仓库独立的修复脚本与项目文档使用 [MIT](LICENSE)。AutoHotkey 是单独运行的解释器，未与修复脚本链接、合编或改动，不在本项目 MIT 授权范围内。上游 AutoHotkey 核心源码的文件头授权为 GPL v2 或（由使用者选择）更高版本[7]；附带组件版权和许可仍按上游声明。上游 [v2.0.28 许可](https://github.com/AutoHotkey/AutoHotkey/blob/v2.0.28/license.txt)包含 GPL v2 全文和额外第三方声明，随本仓库以 [`AutoHotkey-LICENSE.txt`](AutoHotkey-LICENSE.txt) 保存[1]。

The original script and project documentation are MIT-licensed. The unmodified, separately invoked AutoHotkey executables, corresponding source archive, and notices are **not** covered by the project's MIT license. AutoHotkey's source headers permit GPL version 2 or (at your option) any later version.[7] The upstream license file includes third-party notices; retain it with redistributions of the runtime.[1]

| 随附文件 / Included file | 来源 / Provenance | SHA-256 |
|---|---|---|
| [`AutoHotkey64.exe`](AutoHotkey64.exe) | Unmodified x64 interpreter from upstream's `AutoHotkey_2.0.28.zip`.[2] | `373181727d1ae858564d4daa678f9fa6cf330d1751f8b284a369c79afdb05e98` |
| [`AutoHotkey32.exe`](AutoHotkey32.exe) | Unmodified x86 interpreter from the same upstream archive.[2] | `461ab9fc31d12658e50cadbb0e079fcf5319582799cf76e5a24883d17dd88568` |
| [`AutoHotkey-2.0.28.zip`](AutoHotkey-2.0.28.zip) | Corresponding upstream source archive for tag `v2.0.28`, commit `8b457eace30288a370c01733df3f5cfaedaa7f05`. Includes the upstream license, Visual Studio solution and projects, and bundled source dependencies.[2][3][6] | `73eae232e45b91d5eb5d80ecee34ff357b6f58fad83a2e624f39a80bcf345b8a` |
| [`AutoHotkey-LICENSE.txt`](AutoHotkey-LICENSE.txt) | Verbatim `license.txt` from the upstream binary archive.[1][2] | — |

The source is offered in the same repository and requires no separate transaction. To build the runtime, extract the source archive and follow its `README.md` (open `AutoHotkeyx.sln` in Visual Studio and select the appropriate build and platform).[3] The local publication check verified provenance and source archive contents; it did not rebuild the upstream executable. No upstream installer, compiled help file, or separate UX sources are redistributed here.

本仓库随二进制提供同版本源码，不只给外链；不附上游安装器、编译帮助文件或不需要的 UX。官方二进制 ZIP 的 SHA-256 为 `b63be7548792b4ad0dfe424d91cc69376694ed2f758245b7a75a0c77d693b478`，用于核对提取来源。[2]

## Sources

[1] https://github.com/AutoHotkey/AutoHotkey/blob/v2.0.28/license.txt
[2] https://github.com/AutoHotkey/AutoHotkey/releases/tag/v2.0.28
[3] https://github.com/AutoHotkey/AutoHotkey/tree/v2.0.28
[6] https://github.com/AutoHotkey/AutoHotkey/archive/refs/tags/v2.0.28.zip
[7] https://github.com/AutoHotkey/AutoHotkey/blob/v2.0.28/source/AutoHotkey.cpp
