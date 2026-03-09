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
    private static let baseURL = URL(string: "https://valuation-service-m8m9.onrender.com")!

    /// Dedicated session with generous timeout for Render free tier cold starts + batch scraping.
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 180
        config.timeoutIntervalForResource = 240
        return URLSession(configuration: config)
    }()

    /// GET /wake — Warm up the Render server to avoid cold start delays on the batch request.
    static func wake() async {
        let url = baseURL.appendingPathComponent("wake")
        var request = URLRequest(url: url)
        request.timeoutInterval = 90
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                print("[ValuationApi] Wake response: \(http.statusCode)")
            }
        } catch {
            print("[ValuationApi] Wake failed (non-fatal): \(error.localizedDescription)")
        }
    }

    /// POST /valuate-batch
    /// - Parameter forceRefresh: If true, skips server-side cache (appends ?forceRefresh=true)
    static func fetchBatchValuation(
        inputs: [PropertyInput],
        forceRefresh: Bool = false
    ) async throws -> ValuationBatchResponse {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("valuate-batch"), resolvingAgainstBaseURL: false)!
        if forceRefresh {
            urlComponents.queryItems = [URLQueryItem(name: "forceRefresh", value: "true")]
        }
        guard let url = urlComponents.url else {
            throw ValuationError.networkError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 180

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

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .timedOut {
            throw ValuationError.timeout
        } catch let urlError as URLError {
            throw ValuationError.networkError(urlError.localizedDescription)
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("[ValuationApi] Response status: \(httpResponse.statusCode), body size: \(data.count) bytes")
            if httpResponse.statusCode >= 500 {
                throw ValuationError.serverError(httpResponse.statusCode)
            }
        }

        do {
            let decoded = try JSONDecoder().decode(ValuationBatchResponse.self, from: data)
            print("[ValuationApi] Decoded \(decoded.valuations.count) valuations")
            for v in decoded.valuations {
                print("[ValuationApi]   \(v.projectName): ₹\(Int(v.fairValue)) (source: \(v.source), confidence: \(v.confidence))")
            }
            return decoded
        } catch {
            throw ValuationError.decodingError(error.localizedDescription)
        }
    }
}
