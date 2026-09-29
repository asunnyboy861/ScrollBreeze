# Capabilities Configuration — Scrollow

## Analysis
Detected from the Chinese guide + us.md (keywords: Screen Time API 四件套, FamilyControls, App Group, CloudKit 同步, 拍照, 订阅, 通知, 深链 scrollow://):

| Requirement | Capability |
|-------------|------------|
| 守护 App / 系统盾牌 | Family Controls + ManagedSettings |
| 跨进程状态共享 (AppGroupStore) | App Groups (`group.com.scrollow.app`) |
| 窗口到期自动重锁 | DeviceActivity extension target |
| 拦截页 UI | ShieldConfiguration extension target |
| Pro 云同步 | iCloud / CloudKit (graceful degradation) |
| 任务拍照 AI 验证 | Camera (NSCameraUsageDescription) |
| 订阅/买断 | In-App Purchase (StoreKit 2) |
| 每日 1 条提醒 | Local notifications (no push entitlement needed) |
| 拦截页跳主 App | URL scheme `scrollow://` |

## Project Structure (auto-created via xcodegen)
- Targets: `Scrollow` (app), `ShieldConfigExtension`, `DeviceActivityExtension`
- App Group `group.com.scrollow.app` in ALL 3 targets' entitlements
- Family Controls entitlement in ALL 3 targets
- DEVELOPMENT_TEAM: JP4TN5PTS3 baked at project level

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Family Controls (Development) | ✅ Configured | Entitlements + auto-provisioning (profile verified includes `com.apple.developer.family-controls`) |
| App Groups `group.com.scrollow.app` | ✅ Configured | Entitlements + auto-provisioning (profile verified includes the group) |
| Camera | ✅ Configured | `NSCameraUsageDescription` in Info.plist |
| URL scheme `scrollow://` | ✅ Configured | `CFBundleURLTypes` in Info.plist |
| PrivacyInfo.xcprivacy | ✅ Configured | All 3 targets (UserDefaults CA92.1, FileTimestamp C617.1) |
| Push Notifications | ➖ Not needed | Reminder is a LOCAL notification (≤1/day, user-scheduled); no aps-environment added |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| Family Controls (Distribution) | ⏳ Pending | Apple Developer portal → request the distribution entitlement with usage statement: "Individual app gating with user consent for mindful screen-time reduction" (required BEFORE App Store submission; one sec / Habit Doom precedents approved) |
| CloudKit container (Pro sync) | ⏳ Deferred | Deliberately omitted from entitlements (v1 is local-first; REST API cannot create containers). When adding Pro sync: enable iCloud capability in Xcode, create container `iCloud.com.zzoutuo.Scrollow` in portal |
| IAP products | ⏳ Pending | Configure 4 products in App Store Connect (see price.md from PHASE 3) |

## No Configuration Needed
- HealthKit, Location, Siri, Watch, Sign in with Apple — not in guide scope
- WidgetKit — guide appendix A target list has only 3 targets; widget/live-activity deferred to a future version

## Verification
- Build succeeded after configuration: ✅ (`xcodebuild -scheme Scrollow -destination 'generic/platform=iOS Simulator'` BUILD SUCCEEDED)
- Signing verification (generic/platform=iOS, -allowProvisioningUpdates): ✅ PASSED — all 3 targets signed with real identity; profile TeamIdentifier = JP4TN5PTS3; entitlements verified inside the profile
- DEVELOPMENT_TEAM: JP4TN5PTS3 (project level)
- PrivacyInfo.xcprivacy: App + ShieldConfigExtension + DeviceActivityExtension

## SDK Notes (Xcode 27 SDK drift — applied in code)
- `ShieldConfigurationDataSource.configuration(shielding application: Application)` (NOT ApplicationToken)
- `UIBlurEffect.Style.systemThick` removed → use `.regular`
- `store.shield.applicationCategories = .specific(tokens)` (policy type, not raw Set)
- `DeviceActivityMonitor.eventDidReachThreshold(_ event:, activity: DeviceActivityName)` / `intervalDidEnd(for activity: DeviceActivityName)` (NOT DeviceActivityReport.Name?)
