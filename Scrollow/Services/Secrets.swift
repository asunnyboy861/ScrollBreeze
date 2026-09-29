import Foundation

struct AIProfile {
    let apiKey: String
    let endpoint: URL
    let model: String
}

enum Secrets {
    static let keychainService = "com.zzoutuo.Scrollow.ai"
    static let keychainAccount = "byo-api-key"
    private static var cachedProfiles: [AIProfile]?

    static func saveBYOKey(_ key: String) {
        KeychainHelper.saveString(key, service: keychainService, account: keychainAccount)
        AppGroupStore.hasBYOKey = !key.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static var byoKey: String? {
        guard let key = KeychainHelper.readString(service: keychainService, account: keychainAccount),
              !key.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return key
    }

    static func deleteBYOKey() {
        KeychainHelper.delete(service: keychainService, account: keychainAccount)
        AppGroupStore.hasBYOKey = false
    }

    static func builtinProfiles() -> [AIProfile] {
        if let cachedProfiles { return cachedProfiles }
        guard let url = Bundle.main.url(forResource: "GLMSecret", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            cachedProfiles = []
            return []
        }
        var profiles: [AIProfile] = []
        for line in text.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
            let parts = trimmed.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count >= 3,
                  let endpoint = URL(string: parts[1]),
                  !parts[0].isEmpty else { continue }
            profiles.append(AIProfile(apiKey: parts[0], endpoint: endpoint, model: parts[2]))
        }
        cachedProfiles = profiles
        return profiles
    }

    static func verificationProfiles() -> [AIProfile] {
        var profiles: [AIProfile] = []
        if let key = byoKey {
            profiles.append(AIProfile(
                apiKey: key,
                endpoint: URL(string: "https://api.z.ai/api/paas/v4/chat/completions")!,
                model: "glm-5.3-flash"))
        }
        profiles.append(contentsOf: builtinProfiles())
        return profiles
    }
}
