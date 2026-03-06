import Foundation

/// URLSession-based network client — mirrors RetrofitClient.kt
enum NetworkClient {

    // Use Mac's local IP — "localhost" only works in simulator, not on physical devices
    static let baseURL = URL(string: "http://10.112.4.43:3000/")!

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
