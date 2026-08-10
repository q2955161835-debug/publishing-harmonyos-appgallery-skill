---
name: publishing-harmonyos-appgallery-skill
description: Use when preparing, signing, verifying, uploading, self-checking, selecting, or submitting a HarmonyOS application through AppGallery Connect, especially for signed APP packages, release certificates and Profiles, Hvigor assembleApp errors, privacy forms, or review submission.
---

# Publishing HarmonyOS on AppGallery

## Overview

Build one evidence chain from accepted commit to verified `.app`, matching portal record, and explicit submission. Current state is evidence; memory is not.

## Required resources

Read both references completely. The verifier lives under this Skill at `scripts/verify-release-package.ps1`.

For Chrome, **REQUIRED SUB-SKILL:** use `chrome:control-chrome`. For DevEco Studio or native dialogs, use `computer-use:computer-use` when available.

## Release gates

| Gate | Required evidence |
| --- | --- |
| Source/signing | Accepted commit and tests; release certificate/Profile match Bundle Name; secrets remain local |
| Package | Project-level `assembleApp` succeeds; `.app` passes digest, signature, Profile, metadata, size, and SHA-256 checks |
| Store basics | `应用信息` is saved and reloaded with an icon for every supported device tab, exactly one category, at least one tag, and a category-related main tag |
| Portal/submission | Parsed identity and report match this upload; user authorizes `提交审核` at action time |

Do not cross a failed gate. Warnings are recorded and classified; they do not replace a successful build or verification result.

## Exact command and error map

```powershell
.\hvigorw.bat --mode module -p product=default -p module=entry@default --no-daemon assembleHap
.\hvigorw.bat --mode project -p product=default --no-daemon assembleApp
pwsh -NoProfile -File '<skill-dir>\scripts\verify-release-package.ps1' -PackagePath '<signed.app>' -DevEcoStudioHome '<DevEco Studio>'
```

Do not invent `buildMode` or other flags; change parameters only when current project configuration proves they are required.

- `00306054 ... assembleApp task not found`: module mode was used for a project task; rerun project-level `assembleApp`.
- `11014007 Key alias password error`: the alias/keystore password is wrong; the user re-enters it locally. It is not a platform version conflict.
- Verification passes only with exit code 0, `verify-app success`, `Digest verify result: true`, and `verify-profile success`.

## Workflow

1. Inspect repository rules, Git/acceptance evidence, release identity, scope, and AppGallery state; then finish validation and checkpoint.
2. Prepare matching release certificate/Profile and local signing without exposing secrets or committing machine data.
3. Build and verify the signed `.app` using the exact map above; compare metadata with source.
4. Open `应用信息` before the version page. For every checked supported-device tab, upload and preview the matching icon; select exactly one category; select at least one tag; set a category-related main tag; click `保存`; reload and verify all four items persisted.
5. Complete the remaining listing, rating, privacy, regions, pricing, declarations, screenshots, and reviewer contact truthfully. Audit both `应用信息` and `准备提交`; never infer that one page covers the other.
6. Upload for `测试和正式上架`, confirm parsing, and match self-check report ID/time to this upload.
7. Use `准备提交` → `版本选取` → choose exact `.app` → `确认选取` → encryption setting → `保存`.
8. Run the portal preflight in `references/release-workflow.md`; do not present a submission summary while any mandatory row is empty or unsaved.
9. Present the submission summary and stop before `提交审核` until action-time confirmation.
10. Distinguish `已提交审核`, `审核通过`, and `已上架`; later manual go-live needs new confirmation.

## Human-only inputs

The user enters passwords, OTPs, and CAPTCHAs locally and accepts legal attestations. Never paste them into chat, scripts, Git, logs, screenshots, or docs.

## Handoff contract

Report commit, Bundle Name, version/build, path/bytes/SHA-256, verification, upload/report identity, regions, state, warnings, and pending authorization.

## Common mistakes

- `BUILD SUCCESSFUL` is not independent release proof; `.hap` is not the store package.
- Match self-check reports to the exact upload.
- Do not start on `准备提交` and overlook `应用信息`: icon, category, tags, and main tag are separate saved requirements.
- A preview alone is not evidence of persistence; save, reload, and re-read every supported-device tab.
- “继续” does not authorize `提交审核` or later go-live.
