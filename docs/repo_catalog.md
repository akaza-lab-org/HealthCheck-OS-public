# HCOS Repository Catalog

HCOS が見守る repository / local-only tool の現況一覧です。

この catalog は「どの project を、どの強さで、次に何を見るか」を一画面で把握するための運用目録です。実際の merge gate、branch protection、Issue template は repository ごとに確認してください。

## Status Definitions

| Status | Meaning |
|---|---|
| `active` | 現在も機能追加・設計変更が継続している |
| `maintenance` | 山場を越え、細部の仕上げ・不具合修正・運用安定が中心 |
| `re-entry` | 休眠または低頻度運用から再始動前の棚卸し中 |
| `paused` | すぐには進めないが、将来候補として残す |
| `inventory-only` | repository 側には変更せず、存在だけ記録する |

## Tier A - Full HCOS Management

| Repository | Local path | Status | Primary use | Next operating focus | Caution |
|---|---|---|---|---|---|
| `akaza-lab-org/HealthCheck-OS` | `C:\path\to\repos\HealthCheck-OS` | `active` | Cross-repo governance, docs, decision memory | Monthly review, repo catalog, knowledge promotion | AI agents must not merge PRs or move Council issues to `council:decision` |
| `akaza-lab-org/clinic-app` | `C:\data\GitHub\kensin` | `maintenance` | Kensin app, reception/doctor/control workflows, PDF output | Polish, regression prevention, cancelled-visit/output safety | Medical logic, fee/order behavior, and production deploys require Human CTO review |
| `akaza-lab-org/AHK_setting` | `C:\path\to\apps\ahk` | `maintenance` | AutoHotkey EMR execution target, launcher, bridge scripts | Small UX improvements, config safety, real-terminal validation | Do not overwrite terminal-specific `config.ini`; preserve manual operation paths |

## Tier B - Advisory Management

| Repository | Local path | Status | Primary use | Next operating focus | Caution |
|---|---|---|---|---|---|
| `akaza-lab-org/summarymaker` | `C:\path\to\repos\summarymaker` | `active` | Diabetes summary app, Gemini, Next.js/Electron | PDF workflow, build reliability, PHI-safe upload flow | Ensure masked/processed images, not original PHI-bearing files, are sent for analysis |
| `akaza-lab-org/pdf_digitizer` | `C:\data\GitHub\pdf_digitizer` | `paused` | PDF coordinate extraction and editor support | Keep scope to ADR-001 Phase 1-2 unless explicitly reopened | Do not silently expand into full clinical document platform |
| `akaza-lab-org/skills` | `C:\path\to\repos\skills` | `active` | Shared Codex/Claude/Antigravity skills | Tier B onboarding complete (skills#4); skill collection, deduplication, reusable workflows | Avoid committing secrets or project-private scratch notes |
| `akaza-lab-org/ikensho_git` | `C:\path\to\repos\ikensho_git` | `re-entry` | Medical document / opinion letter app | Tier B onboarding complete (ikensho_git#2); run re-entry checklist before implementation | Confirm current data model and PHI handling before changes |
| `akaza-lab-org/keikakusho` | `C:\path\to\repos\keikakusho` | `re-entry` | Care plan / clinical support document tool | Tier B onboarding complete (keikakusho#7); run re-entry checklist before implementation | Document output may affect clinical workflow; review generated forms carefully |
| `akaza-lab-org/DM-kousin` | `C:\path\to\repos\DM-kousin` | `re-entry` | Diabetes visit recommendation support | Tier B onboarding complete (DM-kousin#1); run re-entry checklist before implementation | Patient outreach logic can be clinically sensitive |
| `akaza-lab-org/wakumy_apilot` | `C:\path\to\repos\wakumy_apilot` | `re-entry` | Round visit / vaccination management support | Tier B onboarding complete (wakumy_apilot#1); run re-entry checklist before implementation | Snapshot sync and cancellation state require overwrite-safety review |

## Tier C - Inventory Only

| Tool | Location | Status | Primary use | Next operating focus | Caution |
|---|---|---|---|---|---|
| tobu (トブチケ) | local only | `inventory-only` | Ticket/receipt download support | Keep skill and local notes discoverable | Avoid storing credentials in repo |
| chatworks | local only | `inventory-only` | Chatwork-related local automation | Decide whether it deserves a repo or skill | Confirm API token handling before repo creation |
| 講演会スライド | Google Drive | `inventory-only` | Lecture slide assets | Keep clinical-lecture refinement workflow separate | Google Drive assets may contain private or licensed material |

## Monthly Review Fields

During monthly HCOS review, update these fields when they changed:

- status
- next operating focus
- local path
- current parent Issue or active PR
- safety caution

Do not mark a repository as Tier A unless its repository-local templates, workflows, and branch protection have actually been verified.
