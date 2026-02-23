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
