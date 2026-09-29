# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Scrollow |
| **Git URL** | git@github.com:asunnyboy861/Scrollow.git |
| **Repo URL** | https://github.com/asunnyboy861/Scrollow |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Scrollow/ | ✅ Active |
| Support | https://asunnyboy861.github.io/Scrollow/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/Scrollow/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/Scrollow/terms.html | ✅ Active (subscription app) |

## Repository Structure

```
Scrollow/
├── Scrollow.xcodeproj/            # Xcode Project (xcodegen)
├── Scrollow/                      # iOS App Source Code
│   ├── App/                       # Entry + deep link (scrollow://breathe)
│   ├── Views/                     # Onboarding / Today / Breathe / Tasks / Gate / Settings / Components
│   ├── ViewModels/                # GateModel / BreathModel / HomeModel / TaskModel / WeeklyModel
│   ├── Models/                    # AppGroupStore / ReclaimTask / GateEvent (SwiftData)
│   ├── Services/                  # MotionVerifier / EdgeAI / Secrets / PurchaseManager / KeychainHelper
│   └── GLMSecret.txt              # ⚠️ EXCLUDED from repo (.gitignore — AI key profiles)
├── ShieldConfigExtension/         # Shield interception page UI
├── DeviceActivityExtension/       # System-level relock monitor
├── docs/                          # Policy Pages (GitHub Pages source)
├── .github/workflows/
│   └── deploy.yml
├── project.yml                    # xcodegen manifest (3 targets)
├── us.md
├── capabilities.md
├── icon.md
├── price.md
├── nowgit.md
├── app_review_info.md
├── improvement_plan_1.md
├── keytext.md                     # ⚠️ EXCLUDED from repo (.gitignore — confidential ASO strategy)
└── COMPETITOR_REPORT.md           # ⚠️ EXCLUDED from repo (.gitignore — confidential competitor analysis)
```
