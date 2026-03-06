import Foundation

/// Portfolio API — mirrors PortfolioApi.kt (Retrofit interface)
enum PortfolioApi {

    /// POST /portfolio-summary
    static func fetchSummary(
        inputs: [PropertyInput] = SamplePortfolioData.propertyInputs
    ) async throws -> PortfolioApiResponse {
        let url = NetworkClient.baseURL.appendingPathComponent("portfolio-summary")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = PortfolioRequest(
            properties: inputs.map { p in
                PropertyInputDTO(
                    projectName: p.projectName,
                    city: p.city,
                    locality: p.locality,
                    areaSqft: p.areaSqft,
                    purchasePrice: p.purchasePrice,
                    purchaseYear: p.purchaseYear,
                    monthlyRent: p.monthlyRent
                )
            }
        )
        request.httpBody = try NetworkClient.encoder.encode(body)

        let (data, _) = try await NetworkClient.session.data(for: request)
        return try NetworkClient.decoder.decode(PortfolioApiResponse.self, from: data)
    }
}

// ─── Valuation API (99acres valuation service on port 3001) ──────────────────

enum ValuationApi {
    #if DEBUG
    private static let baseURL = URL(string: "http://localhost:3001")!
    #else
    private static let baseURL = URL(string: "https://reportfolio-valuation.onrender.com")!
    #endif

    /// Dedicated session with longer timeout — scraping multiple properties can take 60-90s.
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 180
        return URLSession(configuration: config)
    }()

    /// POST /valuate-batch
    static func fetchBatchValuation(
        inputs: [PropertyInput]
    ) async throws -> ValuationBatchResponse {
        let url = baseURL.appendingPathComponent("valuate-batch")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let body = ValuationBatchRequest(
            properties: inputs.map { p in
                ValuationInputDTO(
                    projectName: p.projectName,
                    city: p.city,
                    locality: p.locality,
                    societyName: p.societyName,
                    areaSqft: p.areaSqft,
                    purchasePrice: p.purchasePrice,
                    monthlyRent: p.monthlyRent,
                    floorPlan: p.floorPlan?.rawValue
                )
            }
        )
        request.httpBody = try JSONEncoder().encode(body)

        print("[ValuationApi] POST \(url.absoluteString) with \(inputs.count) properties")

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("[ValuationApi] Response status: \(httpResponse.statusCode), body size: \(data.count) bytes")
        }

        let decoded = try JSONDecoder().decode(ValuationBatchResponse.self, from: data)
        print("[ValuationApi] Decoded \(decoded.valuations.count) valuations")
        for v in decoded.valuations {
            print("[ValuationApi]   \(v.projectName): ₹\(Int(v.fairValue)) (source: \(v.source))")
        }
        return decoded
    }
}
