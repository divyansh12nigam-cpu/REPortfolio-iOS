import Foundation

/// URLSession-based network client — mirrors RetrofitClient.kt
enum NetworkClient {

    #if DEBUG
    static let baseURL = URL(string: "http://localhost:3001/")!
    #else
    static let baseURL = URL(string: "https://reportfolio-valuation.onrender.com/")!
    #endif

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
