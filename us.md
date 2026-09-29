# Scrollow — iOS Development Guide

> Translated & structured from the Chinese operation guide (TR-20260916, 2026-09-16).
> Source of truth for all phases: PHASE 2 (project config), PHASE 3 (pricing), PHASE 4+5 (code generation).

## Executive Summary

**Scrollow** ("Scroll + Slow", rhymes with *pillow*) is a native SwiftUI screen-time mindfulness gatekeeper. Before opening a guarded app (TikTok, Instagram, …), the user must complete **3 breaths (~8s)** — or, alternatively, complete a **replacement-behavior task** (squats / walk / tidy desk) verified by **AI photo analysis** to earn a longer conscious-use window.

**Core loop**: urge → shield page with breathing ring → most users quit ("+12 min reclaimed today" 🎉) → those who need it pick a window (5/15/30 min) → OS-level auto relock when the window expires, guilt-free.

**Key differentiators (the "crushing points")**:
1. **Replacement-behavior unlock** — breath → micro-task → conscious window (vs. pure friction in one sec / ScreenZen).
2. **AI visual verification of tasks** — unique on iOS (GLM-5.3-Flash via api.z.ai; Apple Foundation Models on-device fallback; honor mode last resort).
3. **OS-level enforcement** — ManagedSettings shield blocks 4/5 known bypass methods; deletion is impossible to block and we say so honestly (trust marketing).
4. **Zero data-anxiety design** — ONE number ("47 min reclaimed"), no charts, no infinite scroll, no red badges anywhere.
5. **Breathing unlock is free forever** — the entire core loop is in the free tier; transparent pricing ($29.99/yr vs Opal $99.99/yr).
6. **AI cost structure** — on-device Apple Foundation Models (iOS 26+) free; GLM only fires on the visual-verification moment (<1¢/call); BYO-key tier = zero platform AI cost.

- **Tech stack**: SwiftUI + MVVM, FamilyControls / ManagedSettings / DeviceActivity / ShieldConfiguration (Screen Time API quartet), App Group, SwiftData, CloudKit, StoreKit 2, Apple Foundation Models (iOS 26+), GLM-5.3-Flash (api.z.ai).
- **Bundle ID**: `com.zzoutuo.Scrollow` ｜ **Min iOS**: 17.0 ｜ **Targets**: Scrollow (app), ShieldConfigExtension, DeviceActivityExtension.
- **App Group**: `group.com.scrollow.app`

## Competitive Analysis (verified 2026-09 via iTunes Search API + market reports)

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Apple Screen Time | Free, built-in | Ignore button = 1/5 enforcement; built for parents | ManagedSettings shield, no one-tap ignore |
| one sec ($19.99/yr) | PNAS-backed (−57% opens) | Skippable, no replacement behavior, no enforcement | OS-level shield + task unlock + free core loop |
| ScreenZen (free) | Progressive delay 10s→60s | Plateaus ~30% reduction; hardcore users pass through | Relative-threshold relock, behavior change not just delay |
| Opal ($99.99/yr) | Strong locks (4/5) | "Hate-it" pricing; bloated into productivity OS | $29.99/yr, one-screen minimalism, free tier is the whole loop |
| Clearspace ($49.99/yr) | Friction + social accountability | Weak solo | Solo-first, mindfulness-native |
| Habit Doom ($4.99/mo) | Task-complete-to-unlock + AI proof (4/5) | Productivity-oriented, expensive monthly | Mindfulness/replacement-behavior identity, $29.99/yr |
| Brick ($59 hardware) | Max enforcement (5/5) | Needs hardware, narrow audience | Pure software, zero hardware |
| RepsForReels ($4.99/mo) | AI pose verification → screen time | **Android only** — iOS gap! | We own the iOS gap: AI-verified exercise → window |
| Floga (replication target) | Lifetime tiers validated ($109/$199/$349, $120K day-one); minimal aesthetic | Never touched Screen Time API; mindfulness disconnected from blocking | We integrate mindfulness INTO the highest-frequency blocking moment |

**Category "unsolved triangle"**: enforcement × behavior change × price-friendly. No competitor holds all three. Scrollow does.

## ⚠️ Feature Inventory (MANDATORY — Every Feature Must Be Listed)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | Onboarding (3 screens, ≤60s, zero forms) | Open app → Screen 1: pick ≤3 apps via system FamilyActivityPicker → Screen 2: pick one intent ("Sleep better"/"Focus at work"/"Be present") → Screen 3: trial breath (3 cycles) → done; shield armed immediately | App selection tokens, intent string | Save selection + intent; arm ManagedSettings shield | Confirmation + playful copy ("You just said no to an imaginary Instagram") | FamilyActivitySelection JSON → App Group UD; intent → App Group UD | After onboarding, opening a guarded app shows the Scrollow shield page |
| 2 | Gate management (FamilyControls) | Settings → Gate tab → authorize (.individual) → select apps | AuthorizationCenter status, FamilyActivitySelection | Store tokens in App Group; `store.shield.applications = tokens` | Shield applies to selected apps system-wide | Selection JSON in App Group UD (`group.com.scrollow.app`) | Kill Scrollow, reboot — shield still enforces |
| 3 | Shield interception page (extension) | User taps guarded app → system presents shield | ApplicationToken | ShieldConfiguration extension renders static UI (no network/no unlock allowed by OS) | Deep-space gradient + breath-ring icon + "One scroll, three breaths." + buttons "Open Scrollow" / "Actually… no thanks 👋" | — (stateless) | Shield shows within ~1s of tapping guarded app; primary button deep-links to main app |
| 4 | Breath ring engine | Shield → "Open Scrollow" deep link → breath page: ring expands 4s / contracts 4s × 3 cycles | None (time + haptics) | Minimum 8s validation (anti-tap-spam); haptic on each cycle; star-dust burst + notification haptic on completion | Ring animation, star dust, "+X min reclaimed today" | Breath completion event → SwiftData log; reclaimed minutes → App Group UD | Ring completes 3 cycles in ~8s; unlock button only enabled after ≥8s since shield tap |
| 5 | Give-up celebration (the dopamine moment) | On shield "no thanks" OR after breathing user chooses "Not now" | Breath completion timestamp | Compute estimated reclaimed minutes; +1 water drop 💧 | Burst animation + "Reclaimed 12 min today" | reclaimedMinutesToday += N, waterDrops += 1 in App Group UD; event → SwiftData | Home screen big number increments; water drop count +1 |
| 6 | Conscious-use window | After breath → choose 5 / 15 / 30 min (free: 5-min tier unlimited; 15-min free during intro?) | Selected minutes | `grant(windowMinutes:)` → unlockUntil = now + m*60 in App Group UD; clear ManagedSettings shield; schedule DeviceActivity relative-threshold relock event | "Enjoy it. We'll hold the door." → user manually returns to guarded app | unlockUntil (App Group UD — single source of truth) | Guarded app usable immediately; shield re-arms at window end WITHOUT app alive |
| 7 | Auto-relock (DeviceActivity extension) | System event | DeviceActivityEvent threshold (relative usage seconds = window minutes*60) | `eventDidReachThreshold` / `intervalDidEnd` → relock: shield re-applied, unlockUntil = .distantPast | Shield reappears; optional gentle note "Door closed gently. See you." | Event log → SwiftData | Clock-change immune (relative threshold); relock fires after force-kill/reboot of Scrollow |
| 8 | Home screen (Today tab) | Open Scrollow | App Group UD reads | Aggregate today's reclaimed minutes | ONE big number ("47 min reclaimed"), water-drop bottle (weekly), no charts | Reads App Group UD; history → SwiftData | Opens <1s; no infinite scroll; no red badges |
| 9 | Replacement-task center (Pro) | On shield flow → "Earn a longer window" → task card (10 squats / 5-min walk / tidy desk) → take photo | JPEG photo (~100KB, in-memory only) | Verification chain: Apple Foundation Models (iOS 26+, on-device) → GLM-5.3-Flash vision (api.z.ai, 10s timeout, 1 retry) → honor mode (half duration) | Verdict {pass, confidence, reason}; on pass: ring turns green "Earned. Not borrowed." + 30-min window + 💧+1; on fail: gentle retry hint | Verdict → SwiftData; photo NEVER persisted (set nil immediately) | Pass grants 30-min window; no network + both AI fail → honor mode grants HALF duration, never fake-pass |
| 10 | AI verification via GLM-5.3-Flash | Sub-flow of #9 | base64 JPEG + task prompt | POST https://api.z.ai/api/paas/v4/chat/completions, model glm-5.3-flash, temperature 0.1, response_format json_object, requestId idempotency dedup | JSON verdict; fail → retry (free retries) | requestId set in-memory | Duplicate photo submission does not double-charge; timeout → fallback chain |
| 11 | Weekly insight (one sentence) | Sunday / weekly card on Home | SwiftData event logs → local aggregation | On-device summary; iOS 26+: Foundation Models one warm sentence + one suggestion; else GLM text (Pro) ; else template string | One sentence + one tappable suggestion ("Want a night gate? [yes]") | Weekly card cached locally | Never a chart wall; suggestion one-tap applies |
| 12 | StoreKit 2 paywall | Appears ONLY after first earned task or via soft card on Home; skippable forever | Product list | Load products; purchase; entitlement local (no server) | Prices ALWAYS plaintext; "Free tier is free forever. Cancel in 2 taps: Settings → Subscription." | isPro / byoOwned / classicOwned flags in App Group UD | Restore Purchases works; trial terms shown before purchase |
| 13 | BYO API key (Settings) | Settings → Advanced → paste Z.ai/BigModel key | Key string | Stored in Keychain; enables unlimited AI verification with user's own balance | AI works without subscription | Keychain (never UserDefaults/iCloud) | With key set, task verification uses user's endpoint |
| 14 | Settings & compliance | Tabs: Today / Gate + Settings sheet | — | Links: Privacy Policy, Terms, Cancel-in-2-taps tutorial; guarded-app editor; night gate (Pro); notification timing (max 1/day, user-chosen) | System settings deep links | Prefs in App Group UD | All legal links functional; no dark patterns |
| 15 | Night gate (Pro) | Settings → Night Gate → time range | Start/end hours | Extra shield during range via ManagedSettingsStore schedule | Shield active at night | Schedule in App Group UD | Night range enforced system-level |

### Sub-Features & Detail Interactions

| # | Parent | Sub-Feature | Detail | Interaction |
|---|--------|-------------|--------|-------------|
| 1.1 | Onboarding | Screen 3 easter egg | After trial breath: "You just said no to an imaginary Instagram." | Auto after 3rd breath |
| 4.1 | Breath ring | Haptics scale | Light on each inhale-exhale transition; .success notification on completion; .medium impact on unlock | Timed with animation |
| 5.1 | Celebration | Star-dust particle burst | Ring explodes into particles, ≤400ms animations | On give-up / earn |
| 6.1 | Window | Post-window copy | "Door closed gently. See you." — no guilt, never "you wasted…" | On relock event, next open |
| 9.1 | Tasks | Honor mode | No network or both AI backends fail → self-attested, window duration HALVED. Never fake-pass (App Review honesty) | Automatic fallback |
| 9.2 | Tasks | Photo privacy | base64 in memory only; nil'd after verdict; Privacy Manifest declares no storage/no CloudKit/no training | Always |
| 12.1 | Paywall | Placement rule | Only after first AI-earned task, or soft card on Home; never blocks onboarding | Per guide §5.1 |
| 14.1 | Settings | Share card | "Share my reclaimed score" generates watermark-free image | Tap |

### Cross-Feature Dependencies

| Dependency | Source | Target | Data Passed | Trigger |
|------------|--------|--------|-------------|---------|
| Shield → Breath | #3 Shield page | #4 Breath engine | Deep link (scrollow://breathe) + shield-tap timestamp | Primary shield button tap |
| Breath → Window | #4 | #6 | Breath completion (≥8s validated) | 3rd breath ends |
| Window → Relock | #6 | #7 | DeviceActivity schedule + relative threshold event | Grant window |
| Relock → Home copy | #7 | #8 | Relock event log | Window ends |
| Task pass → Window+Drop | #9/#10 | #6/#5 | Verdict.pass → 30-min grant + waterDrops+1 | AI pass |
| Purchase → Gating | #12 | #9/#15 | isPro flag via App Group UD | Successful purchase |
| Logs → Weekly | #1–#9 events | #11 | SwiftData event stream | Weekly aggregation |

**VERIFICATION**: 15 primary features + 8 sub-features extracted — matches guide §§4–9 (core loop, task center, AI chain, paywall, weekly, settings, night gate, share). ✅

## Apple Design Guidelines Compliance

- **Screen Time API entitlement**: Family Controls (Distribution) — usage statement: *"Individual app gating with user consent for mindful screen-time reduction."*
- **Privacy Manifest**: collection = none (no account); photos = not stored; UserDefaults reason CA92.1.
- **Guideline 3.1.2**: trial price disclosed pre-purchase; Restore Purchases; cancel tutorial page.
- **Health claims red line**: only "reduce screen time / build awareness" — NEVER medical/therapeutic claims.
- **HIG**: dark-first deep-space blue (#0D1226), supports Light auto; SF Pro Display; 64pt bold hero number; haptics throughout; ≤400ms animations; Dynamic Type respected; accessibility labels on breath ring.
- **Honesty marketing**: FAQ states deleting Scrollow removes protection (trust differentiator).

## ⚠️ App Store Compliance — AI Features

### Apple Intelligence (Default Free AI Backend)
- iOS 26+: Foundation Models (`LanguageModelSession`) runs weekly insight & simple task checks on-device — free, private, offline.
- iOS < 26 / visual-detail tasks / no model: fall to GLM-5.3-Flash (api.z.ai), then honor mode (half duration). **Never fake a pass.**
- Simulator: Apple Intelligence unavailable → BYO key or honor mode for testing.
- Guideline 2.1(a): create `app_review_info.md` with demo instructions; no dead AI buttons; no free-generation counters (no `freeGenerationsUsed` / `maxFreeGenerations` — FORBIDDEN dead code).

### BYO API Key
- Settings → Advanced: user's Z.ai/BigModel key (Keychain). BYO tier ($49.99 non-consumable) = unlimited AI, zero platform cost.
- Guideline 3.1.2(c): paywall shows title, length, price, auto-renewal text, Privacy Policy + Terms links.

## ⚠️ App Store Compliance — Subscriptions

- Products: `scrollow.pro.monthly` ($4.99), `scrollow.pro.yearly` ($29.99, 7-day trial), `scrollow.byo.lifetime` ($49.99 non-consumable), `scrollow.classic.lifetime` ($79.99 non-consumable — all non-cloud-AI features forever).
- **Rule**: any feature consuming GLM API must NEVER be sold as lifetime non-consumable without user's own key (BYO) — cloud-AI consumption is subscription/BYO only.
- Entitlement resolution: local StoreKit 2 (`Transaction.currentEntitlements`), no server.
- Paywall copy: "Free tier is free forever. Cancel in 2 taps: Settings → Subscription."

## Technical Architecture

- **Language**: Swift 5.9+, SwiftUI-first, MVVM.
- **Min iOS**: 17.0. Foundation Models behind `if #available(iOS 26, *)`.
- **Screen Time APIs**: FamilyControls (authorization), ManagedSettings (shield), DeviceActivity (relative-threshold relock), ManagedSettingsUI (shield page).
- **State**: AppGroupStore (App Group UserDefaults) = SINGLE source of truth for `unlockUntil`, `shieldOn`, `waterDrops`, selection, entitlements. SwiftData = event logs only.
- **Data**: SwiftData + CloudKit (Pro sync); Keychain for BYO key.
- **Networking**: URLSession async/await; 10s timeout, 1 retry, then degrade.
- **Reliability iron rules (from guide §6.2)**:
  1. Single source of truth (App Group UD).
  2. Relock never depends on app being alive (DeviceActivity system event).
  3. Clock-change immune (relative duration thresholds, never absolute-time compare).
  4. AI idempotency: UUID requestId dedup.
  5. Fixed fallback chain: on-device → GLM → honor mode (half). Never fake-pass.
  6. Photo ephemeral: memory base64, nil after verdict.
  7. Offline-complete: breath → unlock → relock works 100% without network.

## Module Structure

```
Scrollow/
├── Scrollow/                        # Main app target
│   ├── ScrollowApp.swift            # Entry, deep-link (scrollow://breathe)
│   ├── Models/
│   │   ├── AppGroupStore.swift      # Single source of truth
│   │   ├── ReclaimTask.swift        # Task catalog
│   │   ├── Verdict.swift
│   │   └── EventLog.swift           # SwiftData entity
│   ├── Views/
│   │   ├── Onboarding/ (3 screens)
│   │   ├── Today/ (HomeView, WaterDropBottle, WeeklyCard)
│   │   ├── Breathe/ (BreathRingView, StarDust, WindowPickerView)
│   │   ├── Tasks/ (TaskCenterView, TaskCaptureView, VerdictView)
│   │   ├── Gate/ (GateView, FamilyActivityPicker wrapper, NightGateView)
│   │   └── Settings/ (SettingsView, PaywallView, CancelTutorialView, BYOKeyView)
│   ├── ViewModels/ (GateModel, BreathModel, TaskModel, PayModel, WeeklyModel)
│   ├── Services/
│   │   ├── MotionVerifier.swift     # GLM-5.3-Flash vision (idempotent)
│   │   ├── EdgeAI.swift             # Foundation Models (iOS 26+)
│   │   ├── RelockScheduler.swift    # DeviceActivity schedule helper
│   │   ├── Secrets.swift            # Keychain-backed key access
│   │   └── Haptics.swift
│   └── Assets.xcassets              # App icon (breath ring), PrivacyInfo.xcprivacy
├── ShieldConfigExtension/           # Shield page UI (static, deep-link button)
├── DeviceActivityExtension/         # ActivityMonitor: eventDidReachThreshold → relock
└── project.yml                      # xcodegen (3 targets, App Group, entitlements)
```

## ⚠️ Data Flow Diagram (per core feature)

```
Feature: Intercept → Breathe → Unlock → Relock (core loop)
┌────────────────────────────────────────────────────────────┐
│ User taps Instagram                                        │
│  └─ System shield (ShieldConfigExtension) shows breath CTA │
│      │ deep link scrollow://breathe + tap timestamp        │
│ BreathRingView (main app)                                  │
│  └─ 3 cycles × (4s in + 4s out); validates elapsed ≥ 8s    │
│      │ BreathModel.complete()                              │
│ Decision                                                   │
│  ├─ "Not now" → reclaimedMinutes += est; waterDrops += 1   │
│  │    (App Group UD) → EventLog(SwiftData) → Home number   │
│  └─ Choose window m ∈ {5,15,30}                            │
│       └─ AppGroupStore.grant(m): unlockUntil = now+m*60    │
│            GateModel: store.shield clear                   │
│            RelockScheduler: DeviceActivity relative        │
│            threshold event (m*60 seconds)                  │
│ Window ends (system fires, app-alive-independent)          │
│  └─ DeviceActivityExtension.eventDidReachThreshold         │
│       → relock: shield reapplied, unlockUntil=distantPast  │
│       → EventLog → Home "Door closed gently."              │
└────────────────────────────────────────────────────────────┘

Feature: AI-verified task
User picks task → capture photo (JPEG in memory)
 └─ TaskModel.verify: requestId UUID dedup →
     try EdgeAI (iOS 26+, matched task type)
     catch → MotionVerifier GLM (10s timeout, 1 retry)
     catch → HonorMode(pass, durationHalved=true)
 verdict.pass → grant(30) + waterDrops+1 + EventLog
 verdict.fail → gentle retry (reason hint), photo nil'd
 Photo: NEVER written to disk/CloudKit (Privacy Manifest)
```

## Implementation Flow

1. xcodegen project: 3 targets, App Group `group.com.scrollow.app`, entitlements (Family Controls, App Groups, iCloud/CloudKit, Push optional), DEVELOPMENT_TEAM_ID baked in.
2. AppGroupStore + SwiftData EventLog.
3. FamilyControls authorization flow + FamilyActivityPicker + ManagedSettings arm/clear.
4. ShieldConfigExtension UI (deep-space gradient, breath ring icon, two buttons).
5. BreathRing engine + haptics + star dust + 8s anti-spam validation.
6. Window picker (5/15/30) + grant + DeviceActivity relative-threshold relock scheduling.
7. DeviceActivityExtension monitor (eventDidReachThreshold / intervalDidEnd → relock).
8. Today home (one number, water drops, weekly card) + give-up celebration.
9. Task center + capture + verification chain (EdgeAI → GLM → honor).
10. StoreKit 2 (4 products, entitlement local, restore, cancel tutorial, paywall legal links).
11. BYO key (Keychain) + Settings (night gate Pro, notification timing, share card, legal links).
12. Onboarding 3 screens; paywall placement rules; accessibility + Dynamic Type pass.
13. PrivacyInfo.xcprivacy; app_review_info.md; build-verify iPhone + iPad sims.

## UI/UX Design Specifications

- **Theme**: dark-first deep-space blue `#0D1226`; Light mode auto-supported.
- **Hero visual**: breath ring (teal→indigo radial gradient, blur breathing) — app icon, shield page, loading state, same symbol.
- **Typography**: SF Pro Display; hero number Bold 64pt ("47 min reclaimed"); body 17pt, 1.4 line height.
- **Layout**: one focal element per screen; exactly 2 tabs (Today / Gate); no hamburger.
- **Motion**: all transitions ≤400ms; haptics full coverage (breath=light, success=notification, unlock=impact).
- **Icons**: SF Symbols + single custom water-drop (💧 life-drop currency).
- **Forbidden**: infinite scroll, red badges, notification spam (≤1/day user-scheduled), chart walls, dark-pattern subscriptions.
- **Copy (US casual, self-deprecating humor)**: shield "One scroll, three breaths." / give-up "Actually… no thanks 👋" → "+12 min reclaimed." / unlocking "Enjoy it. We'll hold the door." / relock "Door closed gently. See you." / verified "Earned. Not borrowed." / weekly "Late-night scrolling: -22%. Thursday 11pm is your kryptonite. Want a night gate? [One tap: yes]".

## Code Generation Rules

- SwiftUI + MVVM; one feature per module; high cohesion, low coupling.
- Cross-process state ONLY via AppGroupStore; UI state may be @State.
- Error handling only at two boundaries: AI network (10s timeout → retry once → degrade) and authorization denied (guide to system settings).
- Naming: barrier verbs shield/lock/gate; behavior verbs reclaim/breathe/earn.
- Version read dynamically via `Bundle.main.infoDictionary` — never hardcode.
- No free-generation counters; no fake AI passes; photos ephemeral.
- GLM endpoint: `https://api.z.ai/api/paas/v4/chat/completions`, model `glm-5.3-flash`, temperature 0.1, `response_format: {"type":"json_object"}`.

## Build & Deployment Checklist

1. xcodegen generate → build iPhone + iPad simulators green.
2. Family Controls (Distribution) entitlement requested in developer portal (manual step — user).
3. Privacy Manifest (UserDefaults CA92.1, no photo storage).
4. Subscription products configured in App Store Connect (PHASE 8.5 checklist).
5. TestFlight after DeviceActivity extension tested on real device (shield/simulator caveats documented).
6. App Review notes reference app_review_info.md.

## GitHub Reference Projects (from guide §7.8)

`brianhyun/block`, `MarazziMarco/noescape`, `yeswanth096/Startline-Productivity-App`, `Prakashmaheshwaran/flint-app`, `insidegui/BreatheReplica`, `TheAppWizard/BreatheAnimation`, `0Itsuki0/SwiftUI_iOS_MyBlockMyChoice`, `davide97g/brick`, `Siddhu7007/screen-time-api-agent-skill`, `bansaldehyde/screenly-ios`.
