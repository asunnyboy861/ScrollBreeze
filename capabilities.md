# ScrollBreeze — 配置文档

生成时间：2026-09-29

---

## 一、⚠️ 手动配置（增强功能 — 不配置不影响基本使用）

> **重要说明**：以下配置项均为**增强/上架相关**配置。核心循环（呼吸 → 解锁 → 自动重锁）**零配置即可用**，完全离线运行。配置后可获得完整商业功能（订阅、Pro 云 AI、上架合规）。

### 🔴 Capabilities 增强配置

#### Family Controls (Distribution) 权限 — 上架前必须申请

**影响功能**：不申请则 App Store 分发包无法启用屏幕守护功能（开发/模拟器构建已用 Development 权限验证通过）
**当前状态**：✅ 开发权限（Family Controls Development）已配置且签名验证通过；Distribution 权限需 Apple 后台人工审批

**手动步骤**：
1. 打开 [Apple Developer](https://developer.apple.com) → Contact Us → 申请 **Family Controls (Distribution) Entitlement**
2. 用途说明（Usage Statement）直接粘贴：
   > Individual app gating with user consent for mindful screen-time reduction
3. 同类已通过先例可引用：one sec、Habit Doom 均已上架
4. ⚠️ 审批通常需要数个工作日，建议立即提交；获批后 Xcode 会自动附加到 Archive 签名

#### CloudKit 云同步（可选，本期延后）

**增强功能**：Pro 用户跨设备同步事件日志
**不配置的影响**：仅本地存储，App 正常运行（代码已优雅降级，v1 未启用该 entitlement）
**当前状态**：⏳ 刻意延后 — v1 为本地优先。未来启用时：Xcode → Signing & Capabilities → + iCloud（CloudKit）→ 创建容器 `iCloud.com.zzoutuo.Scrollow`（REST API 无法创建容器，必须 portal 手动操作）

---

### 🔵 IAP StoreKit 配置 — 上架收入必需

**影响功能**：不创建产品则用户无法完成订阅/买断购买

**配置步骤**：
1. 打开 [App Store Connect](https://appstoreconnect.apple.com) → 我的 App → ScrollBreeze → **Features → In-App Purchases**
2. 创建订阅组 **ScrollBreeze Pro**，然后创建以下 4 个产品：

| 产品 | Reference Name | Product ID | 类型 | 价格 |
|------|---------------|-----------|------|------|
| 月付 | ScrollBreeze Pro Monthly | `scrollow.pro.monthly` | 自动续订订阅 | $4.99/月 |
| 年付 | ScrollBreeze Pro Annual | `scrollow.pro.yearly` | 自动续订订阅 | $29.99/年（7 天免费试用）|
| BYO 买断 | ScrollBreeze BYO Lifetime | `scrollow.byo.lifetime` | 非消耗型 | $49.99 一次性 |
| Classic 买断 | ScrollBreeze Classic | `scrollow.classic.lifetime` | 非消耗型 | $79.99 一次性 |

3. Display Name / Description 从 `price.md` 逐字复制（已按 35/55 字符上限校验）：
   - 月付：`ScrollBreeze Pro Monthly` / `Unlimited gate apps, AI tasks, night gate`
   - 年付：`ScrollBreeze Pro Annual` / `All Pro features, 7-day free trial`
   - BYO：`ScrollBreeze BYO Lifetime` / `All Pro features with your own AI key`
   - Classic：`ScrollBreeze Classic` / `All non-AI features forever, one-time`
4. 年付产品需配置 **7 天免费试用**（ introductory offer），试用前明示价格（Guideline 3.1.2）
5. 本地测试：Xcode → File → New → StoreKit Configuration File，按上表录入即可跑通购买流程
6. ⚠️ 产品创建后需等待 Apple 处理（通常 1-2 小时）才可在 App Store 测试

---

### 🟢 Pro 云 AI 内置 Key 配置（增强功能）

**影响功能**：Pro 订阅用户的 AI 拍照任务验证走云端 GLM。不配置时：iOS 26+ 设备走 Apple Intelligence 端侧（免费），否则自动降级荣誉模式（窗口减半），**体验永不断**
**当前状态**：密钥文件框架已建好，等待你填入 key

**配置步骤**：
1. 打开项目中的 `ScrollBreeze/GLMSecret.txt`（已被 .gitignore 排除，**绝不提交 git**）
2. 去掉最后一行注释 `#`，替换为你的真实 key（智谱 BigModel / Z.ai 统一 Key 体系）：
   ```
   你的APIKEY|https://api.z.ai/api/paas/v4/chat/completions|glm-5.3-flash
   ```
3. 可写多行实现双端点故障转移（第二行可填 open.bigmodel.cn 端点）
4. 重新 Build 后 key 打进 App 包；验证：Pro 账号下任务中心拍照 → 观察验证通过
5. ⚠️ 该 key 曾泄露需立即在 [智谱控制台](https://open.bigmodel.cn) 轮换并重写此文件

---

### 🟢 App Store Connect 审核信息配置

**影响功能**：不配置则 Apple 审核员无法测试订阅/Screen Time/AI 功能，Guideline 2.1(a)/3.1.2 拒审风险

**配置步骤**：
1. App Store Connect → ScrollBreeze → **App Review Information**
2. **Notes** 字段：粘贴 `app_review_info.md` 的 "Review Notes" 全部内容（含 Screen Time API 测试步骤、订阅产品 ID、AI BYO 声明、诚实披露）
3. **Privacy Policy URL**：`https://asunnyboy861.github.io/ScrollBreeze/privacy.html`
4. **Terms of Use (EULA) URL**：`https://asunnyboy861.github.io/ScrollBreeze/terms.html`（订阅 App 必填）
5. **Support URL**：`https://asunnyboy861.github.io/ScrollBreeze/support.html`
6. 上架后：把 Apple 分配的 App ID 数字回填到 `docs/index.html` 的 `[APP_STORE_ID]`（替换后 Landing Page 按钮自动变为可下载）

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| Family Controls (Development) | 3 targets entitlement + 自动签名，profile 已验证含该权限 | ✅ 已配置 |
| App Groups `group.com.scrollow.app` | 3 targets 共享，profile 已验证 | ✅ 已配置 |
| DeviceActivity 扩展 | NSExtensionPrincipalClass + SDK 27 签名适配 | ✅ 已配置 |
| ShieldConfiguration 扩展 | 自定义拦截页 + 呼吸圈图标资源 | ✅ 已配置 |
| Camera | NSCameraUsageDescription（照片即焚） | ✅ 已配置 |
| URL Scheme `scrollow://` | 拦截页深链直达呼吸页 | ✅ 已配置 |
| PrivacyInfo.xcprivacy | 3 targets 全覆盖（UserDefaults CA92.1 等） | ✅ 已配置 |
| Outgoing Network | HTTPS 出站（AI 验证 + 客服后端），系统默认允许 | ✅ 已配置 |
| 通知 | 本地通知（每日 ≤1 条用户自选），无需 Push 证书 | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers：`https://feedback-board.iocompile67692.workers.dev/api/feedback` | ✅ 已接入 |
| 政策页 | GitHub Pages：Landing/Support/Privacy/Terms 全部部署 | ✅ 已上线 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | 15/15 特性 MVVM 实现（呼吸圈/窗口/重锁/夜门/周报…） | ✅ 已完成 |
| ContactSupportView | 7 主题磁贴 + 5 必填字段 + 后端对接 + 成功/失败反馈 | ✅ 已完成 |
| PurchaseManager | StoreKit 2 四产品，本地裁决，响应式绑定，恢复购买 | ✅ 已完成 |
| AI 链 | Apple Intelligence（iOS 26+）→ GLM 云端（幂等/10s 超时/双端点）→ 荣誉模式 | ✅ 已完成 |
| 密钥安全 | BYO key 入 Keychain；内置 key 走 gitignored 文件；零硬编码 | ✅ 已完成 |
| QA 迭代 | 7 项问题修复，模拟器 + 真机签名双构建通过，iPhone/iPad 运行验证 | ✅ 已完成 |

### 💡 使用提示（非开发者配置，App 内操作即可）

**AI 功能**：App 默认优先 Apple Intelligence（iOS 26+ 设备端运行，免费、离线、无需任何配置）。低版本设备用户可在 **Settings → AI Configuration → Custom API Key** 输入自己的 key（Keychain 加密存储）。BYO 买断用户 AI 无限次。这是用户操作，非开发者配置。

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub 仓库 | https://github.com/asunnyboy861/ScrollBreeze | ✅ 已推送 |
| GitHub Pages | https://asunnyboy861.github.io/ScrollBreeze/ | ✅ 已启用 |
| App Store 元数据 | keytext.md（17/17 验证通过）+ keytext_inventory.md | ✅ 已生成 |
| 定价配置 | price.md（4 产品 + 合规清单） | ✅ 已生成 |
| 审核资料 | app_review_info.md | ✅ 已生成 |

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据，内容已重组到上方 Section 一 和 Section 二。

### Analysis

检测自中文指南 + us.md 关键词（Screen Time API 四件套、App Group、CloudKit 同步、拍照、订阅、通知、深链 scrollow://）。工程经 xcodegen 自动创建：3 targets（ScrollBreeze / ShieldConfigExtension / DeviceActivityExtension），DEVELOPMENT_TEAM=JP4TN5PTS3 项目级注入。

### No Configuration Needed

- HealthKit、定位、Siri、Watch、Sign in with Apple — 不在指南范围内
- WidgetKit — 指南附录 A 目标列表仅 3 targets，Widget/实时活动延后至未来版本
- Push Notifications — 每日提醒为本地通知，无需 aps-environment

### Verification

- 模拟器构建（generic/platform=iOS Simulator）：✅ BUILD SUCCEEDED
- 签名验证（generic/platform=iOS + allowProvisioningUpdates）：✅ BUILD SUCCEEDED，profile TeamIdentifier=JP4TN5PTS3，含 family-controls + app group
- iPhone 18 Pro / iPad Pro 13" (M5) 运行验证：✅ 安装启动正常，UI 渲染正确
- SDK 27 适配记录：ShieldConfiguration `Application` 类型、blur `.regular`、category `.specific()`、DeviceActivityMonitor `DeviceActivityName` 签名
