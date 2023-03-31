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

let dev = "http://192.168.0.148:3000";
let prod = "http://138.197.140.143:3000";
let baseUrlString = prod;




class NetworkService {
}
