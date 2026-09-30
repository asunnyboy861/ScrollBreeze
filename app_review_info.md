# App Review Information — ScrollBreeze

## Demo Account for Apple Review

### AI Features
The app uses a hybrid AI model:

1. **Apple Intelligence (default, no key needed)**: On iOS 26+, AI task verification and weekly insights run on-device via Foundation Models. Nothing to configure.
2. **Built-in cloud key (developer-provided)**: For visual task verification on older OS versions, a developer-supplied GLM key is bundled via a gitignored resource file (never committed).
3. **BYO API key (optional)**: Users may paste their own Z.ai/BigModel key in Settings → AI Configuration → Custom API Key. Keys are stored in the iOS Keychain.

To test AI task verification on a device/simulator without Apple Intelligence:
1. Open Settings → AI Configuration → Custom API Key
2. Enter any valid Z.ai/BigModel-compatible API key
3. Go to Gate tab → pick apps; then Home → "Breathe & reclaim" → complete 3 breaths → "Earn 30 with a task" → take a photo

If no AI backend is available, the app uses an honest "honor mode": the earned window is granted at HALF duration with a clear disclosure. The app NEVER fakes a verification pass. Breathing unlock (the entire free core loop) requires NO AI and NO configuration.

### Screen Time APIs
- Uses Family Controls (individual), ManagedSettings shield, and DeviceActivity monitoring with user consent for mindful screen-time reduction.
- To test: Gate tab → "Allow Screen Time access" → pick apps via the system picker → "Apply shield now". Opening a guarded app shows the custom shield page.

### Subscription Testing
- `scrollow.pro.monthly` — $4.99/month
- `scrollow.pro.yearly` — $29.99/year, 7-day free trial
- `scrollow.byo.lifetime` — $49.99 one-time (all Pro features + user's own AI key)
- `scrollow.classic.lifetime` — $79.99 one-time (all non-cloud-AI features forever)

### Required Links (In-App)
- Privacy Policy: https://asunnyboy861.github.io/ScrollBreeze/privacy.html
- Terms of Use: https://asunnyboy861.github.io/ScrollBreeze/terms.html
- Support Page: https://asunnyboy861.github.io/ScrollBreeze/support.html

These links are accessible from Settings → Legal & Support, and directly under the Subscribe button on the Paywall.

## Review Notes

### Health Claims
The app makes NO medical or therapeutic claims. Marketing copy is limited to "reduce screen time / build awareness."

### AI Features
- No free-generation counting exists in the code (no `freeGenerationsUsed` / `maxFreeGenerations`).
- AI is an enhancement, not a dependency: the complete core loop (breath → unlock → relock) works fully offline.
- Task photos exist only in memory (base64), are never written to disk or CloudKit, and are nil'd after the verdict.
- The app does not promote any specific AI provider in user-facing UI.

### Honest Enforcement Disclosure
Deleting the ScrollBreeze app removes the system-level shield (an OS limitation for all Screen Time apps). This is disclosed openly in marketing/FAQ as a trust commitment.

### China App Store Compliance
This app does NOT reference ChatGPT/OpenAI in any user-facing UI or metadata. The AI feature uses generic BYO API Key wording ("Custom API Key").
