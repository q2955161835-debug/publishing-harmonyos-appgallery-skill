# publishing-harmonyos-appgallery-skill 项目入口

## 项目目标

本仓库发布一个面向 Codex 的 HarmonyOS / HarmonyOS NEXT AppGallery Connect 发布 Skill。核心目标是把已验收源码、签名 APP、商店资料、合规字段、门户记录、审核整改和最终状态串成可核验的证据链，并在每个外部写操作前保留独立授权门禁。

## 关键入口与目录职责

- `SKILL.md`：Skill 的触发描述、核心门禁、主流程和交付契约，也是公开分发的主描述文件。
- `agents/openai.yaml`：Codex 界面名称、短描述和默认调用提示。
- `references/release-workflow.md`：完整发布、提交、状态验证和驳回整改流程。
- `references/appgallery-form-checklist.md`：应用信息、素材、隐私、合规和版本字段清单。
- `references/troubleshooting.md`：构建、验包、门户、审核和重提故障分流。
- `scripts/verify-release-package.ps1`：签名 APP/HAP 的确定性验包入口。
- `scripts/test-skill-documentation.ps1`：Skill 描述与发布流程的文档契约测试。
- `doc/验收/`、`doc/进展记录/`：长期模块验收、已归档任务结论和按日期记录的执行进展。

## 数据流与安全边界

发布证据流为：Git commit → 项目级 `assembleApp` → 签名 `.app` → 独立验包与 SHA-256 → AppGallery 软件包记录 → 版本选取与字段持久化 → 自检/风险决定 → 经授权提交 → 审核与商店端状态。

密码、私钥、证书、Profile、测试账号秘密、Cookie、OTP、验证码、真实 `.env`、签名配置和构建产物不得提交。应用创建、证书/Profile 变更、上传、自检、门户保存、提交审核、撤销审核和手动发布是相互独立的外部动作。

## 常用验证命令

```powershell
pwsh -NoProfile -File .\scripts\test-skill-documentation.ps1
python -X utf8 "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .
git diff --check
```

PowerShell 脚本语法检查使用 `System.Management.Automation.Language.Parser` 遍历 `scripts/*.ps1`。真实验包测试必须同时提供已授权的包路径与 DevEco Studio 路径；不得用无参数失败冒充测试完成。

## 验收标准

- frontmatter `description` 同时说明 Skill 能力与具体触发场景，`agents/openai.yaml` 与其一致。
- `SKILL.md` 直接路由到完整流程、字段清单、排障文档和验包脚本。
- 文档契约测试、Skill 结构校验、PowerShell Parser 与 `git diff --check` 全部通过。
- 公开提交不含敏感材料、真实发布包、临时调试产物或本机专属配置。
- 任何门户状态只按当前远端记录回读；任何发布动作只在精确授权范围内执行。

## 仓库

- GitHub：<https://github.com/q2955161835-debug/publishing-harmonyos-appgallery-skill>
- 可见性：Public
- 默认分支：`main`
