import Foundation

func getCurrentUserId() -> String? {
    return UserDefaults.standard.string(forKey: "userId")
}

func getToken() -> String? {
    return UserDefaults.standard.string(forKey: "token")
}

func getAccountType() -> String? {
    return UserDefaults.standard.string(forKey: "accountType")
}

extension Date {
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

enum NetworkError: Error {
    case invalidUrl
    case invalidResponse
    case decodingError
}

enum NetworkServiceError: Error {
    case dataError
    case decodeError
}
let baseUrlString = "http://138.197.140.143:1097"




class NetworkService {
}
