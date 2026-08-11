---
name: publishing-harmonyos-appgallery-skill
description: Use when a HarmonyOS AppGallery release involves signing, APP verification, listing fields or assets, privacy/compliance forms, package upload or selection, self-check, review submission, an audit report, review rejection remediation, resubmission, or listing-state verification.
---

# Publishing HarmonyOS on AppGallery

## Overview

Build one evidence chain from an accepted commit to a verified signed `.app`, complete persisted store metadata, the matching portal record, and an explicitly authorized submission. Current files and current portal state are evidence; memory and a successful click are not.

## Required resources

Read these completely before editing AppGallery fields:

- `references/release-workflow.md` for the ordered release and authorization gates.
- `references/appgallery-form-checklist.md` for every application-information, material, privacy, compliance, and version field.

Use `references/troubleshooting.md` when a build, upload, form, self-check, persistence check, audit report, or review rejection needs diagnosis. The verifier lives at `scripts/verify-release-package.ps1`.

For Chrome, **REQUIRED SUB-SKILL:** use `chrome:control-chrome`. For DevEco Studio or native dialogs, use `computer-use:computer-use` when available.

## Release gates

| Gate | Required evidence |
| --- | --- |
| Source/signing | Accepted commit and tests; release certificate/Profile match Bundle Name; secrets remain local |
| Package | Project-level `assembleApp` succeeds; `.app` passes digest, signature, Profile, metadata, size, and SHA-256 checks |
| Application information | Every configured language and material device group has the required name/icon; category, labels, main label, and developer-service fields are saved and reloaded |
| Version information | Exact package, regions, listing copy/assets, rating, privacy, AI, copyright/filing, review information/contact, and launch time are `PASS` or evidence-backed `N/A` |
| Portal/submission | Package legality permits submission; self-check result or explicit skip-risk decision is recorded; user authorizes `提交审核` at action time |
| Review remediation | Audit report identity is bound to the exact audited package; every rejection item has new evidence; user authorizes `重新提交审核` at action time |

Do not cross a failed gate. Huawei describes upper-store self-check as recommended: `待优化` may still permit submission when legality passes, but the risk must be shown and explicitly accepted; never relabel it `通过`.

## Exact command and error map

```powershell
.\hvigorw.bat --mode module -p product=default -p module=entry@default --no-daemon assembleHap
.\hvigorw.bat --mode project -p product=default --no-daemon assembleApp
pwsh -NoProfile -File '<skill-dir>\scripts\verify-release-package.ps1' -PackagePath '<signed.app>' -DevEcoStudioHome '<DevEco Studio>'
```

Do not invent `buildMode` or other flags; change parameters only when current project configuration proves they are required.

- `00306054 ... assembleApp task not found`: module mode was used for a project task; rerun project-level `assembleApp`.
- `11014007 Key alias password error`: the alias/keystore password is wrong; the user re-enters it locally.
- Verification passes only with exit code 0, `verify-app success`, `Digest verify result: true`, and `verify-profile success`.

## Workflow

1. Inspect repository rules, Git/acceptance evidence, release identity, current official requirements, and current AppGallery state; create a rollback checkpoint.
2. Prepare matching release certificate/Profile and local signing without exposing secrets or committing machine data.
3. Build and independently verify the signed `.app`; compare `pack.info`, source configuration, release plan, bytes, and SHA-256.
4. Complete `应用信息` first. Loop through every configured language and every official material device group, not raw package device names; save and reload all fields.
5. Upload the exact verified `.app` for `测试和正式上架`, read the parsed record and legality result, then run or explicitly decide about the recommended self-check.
6. Select that exact package in the version, set encryption, and complete every applicable row in `references/appgallery-form-checklist.md` truthfully.
7. Audit `应用信息` and `版本信息/准备提交` separately. A preview, green check, validation result, or save toast alone is insufficient; reload and re-read persisted values and assets.
8. Produce a field-status preflight. Any required `UNKNOWN`, `BLOCKED`, empty, stale, or unsaved row prevents a final submission summary.
9. Present the exact submission summary and stop before `提交审核` until the user authorizes that version at action time.
10. After submission, distinguish `预审中/审核中`, `审核通过`, `待上架`, and `已上架`.
11. If review fails, follow `references/release-workflow.md` section 11: bind the report to the audited selected package, build an issue matrix, repeat affected local/package/portal gates, and stop before resubmission until newly authorized.

## Human-only inputs

The user enters passwords, test-account secrets, OTPs, and CAPTCHAs locally and accepts legal attestations. Never paste them into chat, scripts, Git, logs, screenshots, acceptance records, or progress documents.

## Handoff contract

Report commit, Bundle Name, version/build, package path/bytes/SHA-256, verification, portal package/upload/report identity, all form statuses, regions, current state, warnings, explicit `N/A` reasons, and pending authorization. After rejection, also report the audited package, report identity, issue matrix, replacement selected package, and resubmission authorization state.

## Common mistakes

- `.hap` is not the store package; `BUILD SUCCESSFUL` is not independent release proof.
- Phone and tablet currently share the official `手机/平板` material tab; do not invent separate uploads, but verify the current portal mapping.
- Screenshots are acceptance evidence: inspect the real rendered frames before upload, then verify count, orientation, dimensions, persistence, and ordering.
- Privacy permission explanation, privacy policy/rights URLs, and privacy labels are different fields; completing one does not complete the others.
- A custom privacy URL that returns 404, redirects to unrelated content, or contradicts the app is not valid evidence.
- A locally fixed APP does not prove AppGallery reviewed or selected it; re-read the selected package row and bind any audit report to that exact file and upload time.
- A slogan that fits the character limit is not automatically a complete one-sentence introduction; state the real user action or outcome.
- Reviewer notes or a demo video may explain reachable functionality, but cannot substitute for real product value or a normally usable release build.
- “继续”, upload authorization, or a saved draft does not authorize `提交审核` or later manual release.
