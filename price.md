# Pricing Configuration — Scrollow

## Monetization Model: Subscription (IAP) + One-Time Buyout Tiers

Free tier includes the complete core loop (breathing unlock is free forever). Pro is auto-renewable; BYO and Classic are non-consumable buyouts. Any feature consuming GLM cloud API is NEVER sold as a non-consumable (BYO excepted — user supplies their own key, zero platform AI cost).

## Subscription Group
- **Group Name**: Scrollow Pro
- **Reference Name**: Scrollow Pro
- **Products in group**: scrollow.pro.monthly, scrollow.pro.yearly (auto-renewable only)

## Subscription Tiers (Auto-Renewable)

### 1. Monthly Subscription
- **Reference Name**: Scrollow Pro Monthly
- **Product ID**: `scrollow.pro.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $4.99 USD per month
- **Display Name**: `Scrollow Pro Monthly` (20 chars, ≤35 ✅)
- **Description**: `Unlimited gate apps, AI tasks, night gate` (41 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Scrollow Pro
- **Restore Purchases**: ✅ Required

### 2. Yearly Subscription
- **Reference Name**: Scrollow Pro Annual
- **Product ID**: `scrollow.pro.yearly`
- **Type**: Auto-renewable subscription
- **Price**: $29.99 USD per year (50% savings vs monthly)
- **Display Name**: `Scrollow Pro Annual` (19 chars, ≤35 ✅)
- **Description**: `All Pro features, 7-day free trial` (34 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Scrollow Pro (same group as monthly)
- **Restore Purchases**: ✅ Required

## One-Time Purchases (Non-Consumable)

### 1. BYO Lifetime
- **Reference Name**: Scrollow BYO Lifetime
- **Product ID**: `scrollow.byo.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $49.99 USD (one-time)
- **Display Name**: `Scrollow BYO Lifetime` (21 chars, ≤35 ✅)
- **Description**: `All Pro features with your own AI key` (37 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Differentiation Note**: BYO includes ALL Pro features permanently; AI verification uses the USER'S OWN Z.ai/BigModel key (Keychain-stored) — unlimited AI calls at zero platform cost. Requires owning a BYO API key; without a key the user should pick Pro instead.

### 2. Classic Lifetime
- **Reference Name**: Scrollow Classic
- **Product ID**: `scrollow.classic.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $79.99 USD (one-time)
- **Display Name**: `Scrollow Classic` (16 chars, ≤35 ✅)
- **Description**: `All non-AI features forever, one-time` (37 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **⚠️ DIFFERENTIATION NOTE**: Classic permanently unlocks all NON-cloud-AI features (unlimited gate apps, 15/30-min windows, night gate, future feature updates). It does NOT include AI visual verification or cloud weekly deep-read (those require Pro subscription, or BYO with the user's own key). Highest price = every feature that has no ongoing cloud cost.

## Free Tier (Default)

- **Price**: Free forever
- **Features**:
  - Guard up to 3 apps (full ManagedSettings shield)
  - Breath unlock (3 breaths / 8s) with unlimited 5-minute windows
  - "Today reclaimed" number + water drops 💧
  - One-sentence weekly report (on-device, iOS 26+)
  - Give-up celebration loop (the core dopamine moment)
  - Honor-mode task fallback (half duration) when AI unavailable
- **Conversion hooks**:
  - "The breathing unlock is free forever — the whole core loop, no countdown."
  - "Free tier is free forever. Cancel in 2 taps: Settings → Subscription."
  - Paywall appears only AFTER the user has earned their first AI-verified window (result first, price after)

## Pro Features Unlocked (All Paid Tiers)

⚠️ Scoped to capabilities.md (implemented features only; CloudKit sync + Widget deferred to a future version and NOT listed).

| Feature | Free | Pro (All Paid Tiers) |
|---------|:----:|:--------------------:|
| Guarded apps | 3 apps | Unlimited |
| Breath unlock, 5-min windows | ✅ Unlimited | ✅ Unlimited |
| 15-min / 30-min windows | ❌ | ✅ |
| AI visual verification tasks (GLM cloud) | ❌ (honor mode only) | ✅ |
| Weekly report deep read (cloud AI, optional) | ❌ (on-device only) | ✅ |
| Night gate (scheduled protection) | ❌ | ✅ |
| BYO API key settings entry | ❌ | ✅ (BYO tier; key required) |

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid subscription)
- **Available for**: scrollow.pro.yearly (price and auto-renewal terms disclosed before purchase)

## Policy Pages Required
- Support Page: ✅ (must include subscription management + cancellation instructions)
- Privacy Policy: ✅
- Terms of Use (EULA): ✅ (REQUIRED — subscription apps must have Terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms will be included in Terms of Use
- [x] Cancellation instructions will be included in Support Page ("Cancel in 2 taps: Settings → Subscription")
- [x] Pricing clearly stated in PaywallView (all four prices plaintext)
- [x] Free trial terms included (7-day yearly trial, disclosed pre-purchase)
- [x] Restore purchases functionality implemented (StoreKit 2 `Transaction.currentEntitlements`)
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options
- [x] No dark-pattern subscriptions (no hidden default selection, no obscured cancel)
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
- [x] BYO Key model: AI generation unlimited with user's own key — no generation counting (`freeGenerationsUsed` / `maxFreeGenerations` forbidden)
- [x] Cloud-AI-consuming features (AI verification, cloud weekly deep-read) sold ONLY via subscription or BYO — never as non-consumable without user's own key
