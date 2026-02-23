import Foundation

/// URLSession-based network client — mirrors RetrofitClient.kt
enum NetworkClient {

    // Base URL: iOS simulator → host machine localhost (same as Android emulator 10.0.2.2)
    static let baseURL = URL(string: "http://localhost:3000/")!

    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .useDefaultKeys
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }()
}
