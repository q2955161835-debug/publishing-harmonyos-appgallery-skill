# HarmonyOS AppGallery 发布与审核整改 Skill

面向 Codex 的 HarmonyOS / HarmonyOS NEXT AppGallery Connect 发布 Skill。它把源码验收、release 签名、签名 `.app` 验证、商店资料、隐私合规、软件包选取、审核整改与上架状态组织成一条可核验的证据链。

这个 Skill 不把“构建成功”“点击上传”或“保存草稿”误当成发布完成，也不会把上传、自检、提交审核、撤销审核和手动上架之间的授权相互推导。

## 适用场景

- 准备新的 HarmonyOS AppGallery 版本或检查发布就绪度。
- 配置 release 证书/Profile，并生成、验证签名 `.app`。
- 填写多语言应用信息、图标、截图、介绍、分类、标签和审核资料。
- 核对隐私说明、隐私政策与权利入口、隐私标签、AI 声明、版权和 APP 备案。
- 上传或选择精确软件包、执行上架自检、生成提交前摘要。
- 处理审核报告、定位名称/图标、文案、兼容 API 或功能价值问题，并准备重提。
- 区分草稿、预审/审核中、审核通过、待上架和已上架等平台状态。

## 核心能力

- 用 Git commit、`pack.info`、文件字节数、SHA-256、验签输出、上传时间和平台记录绑定同一个发布产物。
- 区分模块级 `assembleHap` 设备验收与项目级 `assembleApp` 商店打包。
- 仅在退出码为 0，且出现 `verify-app success`、`Digest verify result: true`、`verify-profile success` 时通过签名包验证。
- 按语言和 AppGallery 当前素材设备组逐项检查资料，并通过保存后刷新/重进证明持久化。
- 审核驳回后用报告、提交快照或不可变平台记录绑定被审核包；证据不足时保持 `UNKNOWN/BLOCKED`。
- 在每个外部动作前检查本次授权，避免误提交、误撤回或误上架。

## 安装

推荐把源码保存在数据盘，再通过 Junction 暴露给 Codex。下面以 PowerShell 为例；请把目标目录替换成你的实际路径。

```powershell
git clone https://github.com/q2955161835-debug/publishing-harmonyos-appgallery-skill.git D:\skills\publishing-harmonyos-appgallery-skill
New-Item -ItemType Directory -Path "$env:USERPROFILE\.codex\skills" -Force
New-Item -ItemType Junction `
  -Path "$env:USERPROFILE\.codex\skills\publishing-harmonyos-appgallery-skill" `
  -Target "D:\skills\publishing-harmonyos-appgallery-skill"
```

如果 Codex 已配置其他 Skill 根目录，也可以直接克隆到该目录。已有同名目录或链接时，先确认它的来源和未提交修改，不要直接覆盖。安装后新开一个 Codex 任务以重新发现 Skill。

## 快速使用

在 Codex 中显式调用：

```text
Use $publishing-harmonyos-appgallery-skill to verify my HarmonyOS release package and prepare the AppGallery submission preflight. Stop before every external write action until I authorize it.
```

也可以直接用中文描述目标，例如：

- “用 `$publishing-harmonyos-appgallery-skill` 检查这个项目是否具备 AppGallery 提交条件，不要上传或提交。”
- “用这个 Skill 核对签名 APP、软件包版本和 SHA-256，然后列出还缺的商店资料。”
- “根据审核报告做整改矩阵，确认当前已选包是否真的是替换包，先停在重新提交审核前。”

## 使用前必读

- 主入口与门禁：[SKILL.md](SKILL.md)
- 完整发布顺序：[references/release-workflow.md](references/release-workflow.md)
- AppGallery 字段与素材清单：[references/appgallery-form-checklist.md](references/appgallery-form-checklist.md)
- 常见故障分流：[references/troubleshooting.md](references/troubleshooting.md)

华为页面、字段、配额和规则可能变化。执行发布任务时应读取当前官方文档和当前 AppGallery Connect 页面，旧截图、旧报告或历史记忆只能用于提出检查项。

## 安全与授权边界

- 密码、私钥、证书、Profile、测试账号秘密、Cookie、OTP、验证码、真实 `.env` 和本机签名配置不得进入聊天、Git、日志、截图或验收记录。
- 创建应用、创建/吊销证书与 Profile、上传包、启动自检、保存门户字段、提交审核、撤销审核和手动发布是不同动作，需要分别授权。
- `.hap` 不是 AppGallery 正式发布包；正式上架使用经过独立验签的 `.app`。
- Skill 提供流程、证据核对和风险门禁，不替用户作法律事实、版权归属、备案类型或隐私合规承诺。

## 本地验证

```powershell
pwsh -NoProfile -File .\scripts\test-skill-documentation.ps1
python -X utf8 "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .
git diff --check
```

真实验包测试还需要一个已授权的签名包和 DevEco Studio 安装目录：

```powershell
pwsh -NoProfile -File .\scripts\test-verify-release-package.ps1 `
  -PackagePath '<signed.app>' `
  -DevEcoStudioHome '<DevEco Studio>'
```

## 目录结构

```text
publishing-harmonyos-appgallery-skill/
├── SKILL.md                         # Codex 触发描述与核心流程
├── agents/openai.yaml               # Codex 界面元数据
├── references/                      # 发布流程、字段清单与故障排查
├── scripts/                         # 验包脚本与文档契约测试
├── doc/验收/                        # 模块和任务验收记录
├── doc/进展记录/                    # 按日期维护的执行进展
└── AGENTS.md                        # 项目维护入口
```

## 许可证

[MIT License](LICENSE)
