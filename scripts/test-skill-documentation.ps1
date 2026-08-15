[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$skillRoot = Split-Path -Parent $PSScriptRoot
$readmePath = Join-Path $skillRoot 'README.md'
$skillPath = Join-Path $skillRoot 'SKILL.md'
$agentConfigPath = Join-Path $skillRoot 'agents\openai.yaml'
$agentsPath = Join-Path $skillRoot 'AGENTS.md'
$gitignorePath = Join-Path $skillRoot '.gitignore'
$workflowPath = Join-Path $skillRoot 'references\release-workflow.md'
$checklistPath = Join-Path $skillRoot 'references\appgallery-form-checklist.md'
$troubleshootingPath = Join-Path $skillRoot 'references\troubleshooting.md'

function Assert-FileContains {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing required file for ${Description}: $Path"
    }

    $content = Get-Content -LiteralPath $Path -Raw
    if ($content -notmatch $Pattern) {
        throw "Missing documentation contract: $Description"
    }
}

Assert-FileContains -Path $skillPath -Pattern '(?m)^name: publishing-harmonyos-appgallery-skill\r?$' -Description 'stable Skill name'
Assert-FileContains -Path $skillPath -Pattern '(?m)^description: .*HarmonyOS.*AppGallery Connect' -Description 'product and platform discovery description'
Assert-FileContains -Path $skillPath -Pattern '(?m)^description: .*signed `\.app` verification' -Description 'signed APP verification trigger'
Assert-FileContains -Path $skillPath -Pattern '(?m)^description: .*localized store metadata or assets' -Description 'listing metadata and asset trigger'
Assert-FileContains -Path $skillPath -Pattern '(?m)^description: .*privacy/compliance/copyright/filing forms' -Description 'compliance trigger coverage'
Assert-FileContains -Path $skillPath -Pattern '(?m)^description: .*rejection remediation.*listing-state verification' -Description 'review remediation and state triggers'
Assert-FileContains -Path $skillPath -Pattern 'appgallery-form-checklist\.md' -Description 'main Skill link to the field checklist'
Assert-FileContains -Path $skillPath -Pattern 'audit report|review rejection|审核报告|审核驳回|审核未通过' -Description 'review rejection trigger'
Assert-FileContains -Path $skillPath -Pattern 'separate external actions' -Description 'external action authorization boundary'

Assert-FileContains -Path $readmePath -Pattern '(?m)^# HarmonyOS AppGallery 发布与审核整改 Skill\r?$' -Description 'GitHub README title'
Assert-FileContains -Path $readmePath -Pattern '(?m)^## 安装\r?$' -Description 'README installation section'
Assert-FileContains -Path $readmePath -Pattern '\$publishing-harmonyos-appgallery-skill' -Description 'README invocation example'
Assert-FileContains -Path $readmePath -Pattern '\[SKILL\.md\]\(SKILL\.md\)' -Description 'README main Skill link'
Assert-FileContains -Path $readmePath -Pattern 'references/release-workflow\.md' -Description 'README release workflow link'
Assert-FileContains -Path $readmePath -Pattern 'references/appgallery-form-checklist\.md' -Description 'README field checklist link'
Assert-FileContains -Path $readmePath -Pattern 'references/troubleshooting\.md' -Description 'README troubleshooting link'
Assert-FileContains -Path $readmePath -Pattern '密码.*私钥.*证书.*Profile' -Description 'README secret boundary'
Assert-FileContains -Path $readmePath -Pattern '提交审核.*撤销审核.*手动发布' -Description 'README external action boundary'
Assert-FileContains -Path $readmePath -Pattern 'MIT License' -Description 'README license link'

Assert-FileContains -Path $agentConfigPath -Pattern 'display_name: "HarmonyOS AppGallery 发布与整改"' -Description 'user-facing Skill name'
Assert-FileContains -Path $agentConfigPath -Pattern 'short_description: ".*签名包.*商店资料.*审核整改' -Description 'user-facing Skill summary'
Assert-FileContains -Path $agentConfigPath -Pattern 'default_prompt: "Use \$publishing-harmonyos-appgallery-skill .*authorization gate\."' -Description 'default invocation prompt'

Assert-FileContains -Path $agentsPath -Pattern 'https://github\.com/q2955161835-debug/publishing-harmonyos-appgallery-skill' -Description 'public repository maintenance entry'
Assert-FileContains -Path $agentsPath -Pattern 'test-skill-documentation\.ps1' -Description 'project validation command entry'
Assert-FileContains -Path $gitignorePath -Pattern '(?m)^\.env\r?$' -Description 'local environment exclusion'
Assert-FileContains -Path $gitignorePath -Pattern '(?m)^\*\.p12\r?$' -Description 'signing keystore exclusion'
Assert-FileContains -Path $gitignorePath -Pattern '(?m)^\*\.app\r?$' -Description 'release artifact exclusion'

Assert-FileContains -Path $workflowPath -Pattern '每种语言' -Description 'localization loop'
Assert-FileContains -Path $workflowPath -Pattern '素材设备组' -Description 'device-group asset loop'
Assert-FileContains -Path $workflowPath -Pattern '上架自检.*推荐' -Description 'official self-check semantics'
Assert-FileContains -Path $workflowPath -Pattern '审核报告身份' -Description 'review report identity gate'
Assert-FileContains -Path $workflowPath -Pattern '被审核软件包' -Description 'audited package binding'
Assert-FileContains -Path $workflowPath -Pattern '不可变.*记录|提交.*快照|提交快照' -Description 'immutable audited package evidence'
Assert-FileContains -Path $workflowPath -Pattern '无法.*唯一.*证明.*(UNKNOWN|BLOCKED)|无法.*(UNKNOWN|BLOCKED).*重提摘要' -Description 'unknown audited package fail-closed gate'
Assert-FileContains -Path $workflowPath -Pattern '驳回问题矩阵' -Description 'review rejection remediation matrix'
Assert-FileContains -Path $workflowPath -Pattern '重新提交.*授权|授权.*重新提交' -Description 'resubmission authorization gate'

$checklistContracts = [ordered]@{
    'phone and tablet shared asset tab' = '手机/平板.*共用'
    'phone/tablet icon resolutions' = '216×216.*1024×1024'
    'phone/tablet screenshot count' = '3-5张'
    'landscape screenshot resolution' = '1920×1080'
    'portrait screenshot resolution' = '1080×1920'
    'privacy permission explanation' = '应用隐私说明'
    'privacy policy URL' = '隐私政策网址'
    'privacy rights URL' = '隐私权利'
    'privacy label' = '隐私标签'
    'AI declaration' = 'AI功能声明'
    'standalone app filing path' = '单机APP'
    'copyright proof' = '应用版权证书或代理证书'
    'review test account' = '测试账号'
    'reviewer SMS verification' = '验证码'
    'installed name and icon consistency' = '安装后.*名称.*图标|终端.*名称.*图标'
    'functional one-sentence copy' = '一句话简介.*完整.*功能|完整功能句'
    'compatible and target API separation' = 'compatible.*target|minAPIVersion.*targetSdkVersion'
    'auditable functional value' = '审核可达|可达性'
    'selected package readback' = '已选软件包|版本选取.*回读'
    'official material specification source' = 'agc-help-app-visual-asset-spec'
    'official privacy source' = 'agc-help-release-app-privacy-state'
    'official filing source' = 'agc-help-release-app-record'
}

foreach ($contract in $checklistContracts.GetEnumerator()) {
    Assert-FileContains -Path $checklistPath -Pattern $contract.Value -Description $contract.Key
}

$troubleshootingContracts = [ordered]@{
    'review still used old package' = '旧包|被审核软件包'
    'review reports minimum API too high' = '最低适配|兼容 API'
    'review reports limited functionality' = '功能.*有限|场景.*有限'
}

foreach ($contract in $troubleshootingContracts.GetEnumerator()) {
    Assert-FileContains -Path $troubleshootingPath -Pattern $contract.Value -Description $contract.Key
}

Write-Host 'Skill documentation contract tests passed.'
