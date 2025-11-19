import Foundation

protocol KeyChainManaging {
    func save(token: String)
    func read() -> String?
    func delete()
}
