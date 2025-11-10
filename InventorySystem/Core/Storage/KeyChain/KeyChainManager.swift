import Security
import Foundation

final class KeychainManager: KeyChainManaging {
    static let shared = KeychainManager()
    private let key = "com.InventorySystem.auth.accessToken"
    private init() {}
    
    func save(token: String) {
        if let data = token.data(using: .utf8) {
            // Delete existing
            delete()
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &item)
        
        guard let data = item as? Data,
              let token = String(data: data, encoding: .utf8)
        else { return nil }
        
        return token
    }
    
    func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
