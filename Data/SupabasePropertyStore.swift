import Foundation
import Supabase

/// Cloud CRUD for user properties in the `user_properties` Supabase table.
enum SupabasePropertyStore {

    // MARK: - Fetch all properties for the current user

    static func fetchAll() async throws -> [PropertyInput] {
        let rows: [UserPropertyRow] = try await SupabaseManager.client
            .from("user_properties")
            .select()
            .order("sort_order")
            .execute()
            .value

        return rows.map { $0.toPropertyInput() }
    }

    // MARK: - Replace all properties (full sync up)

    /// Upload all local properties to cloud, replacing any existing rows.
    static func replaceAll(userId: String, inputs: [PropertyInput]) async throws {
        // Delete existing rows
        try await SupabaseManager.client
            .from("user_properties")
            .delete()
            .eq("user_id", value: userId)
            .execute()

        // Insert all with sort order
        let rows = inputs.enumerated().map { i, input in
            UserPropertyInsert(userId: userId, input: input, sortOrder: i)
        }
        if !rows.isEmpty {
            try await SupabaseManager.client
                .from("user_properties")
                .insert(rows)
                .execute()
        }

        print("[CloudStore] Uploaded \(rows.count) properties for user \(userId)")
    }

    // MARK: - Add a single property

    static func addProperty(userId: String, input: PropertyInput, sortOrder: Int) async throws {
        let row = UserPropertyInsert(userId: userId, input: input, sortOrder: sortOrder)
        try await SupabaseManager.client
            .from("user_properties")
            .insert(row)
            .execute()
    }

    // MARK: - Update a single property by sort order

    static func updateProperty(userId: String, input: PropertyInput, sortOrder: Int) async throws {
        let update = UserPropertyUpdate(input: input, sortOrder: sortOrder)
        try await SupabaseManager.client
            .from("user_properties")
            .update(update)
            .eq("user_id", value: userId)
            .eq("sort_order", value: sortOrder)
            .execute()
    }

    // MARK: - Delete a single property by sort order

    static func deleteProperty(userId: String, sortOrder: Int) async throws {
        try await SupabaseManager.client
            .from("user_properties")
            .delete()
            .eq("user_id", value: userId)
            .eq("sort_order", value: sortOrder)
            .execute()
    }
}

// MARK: - Row DTOs

/// Matches `user_properties` table columns (for reading).
private struct UserPropertyRow: Decodable {
    let id: String
    let userId: String
    let projectName: String
    let city: String
    let locality: String
    let areaSqft: Int
    let purchasePrice: Int64
    let purchaseYear: Int
    let monthlyRent: Int
    let societyName: String
    let floorPlan: String?
    let customName: String
    let purchaseMonth: String
    let usageType: String?
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case projectName = "project_name"
        case city, locality
        case areaSqft = "area_sqft"
        case purchasePrice = "purchase_price"
        case purchaseYear = "purchase_year"
        case monthlyRent = "monthly_rent"
        case societyName = "society_name"
        case floorPlan = "floor_plan"
        case customName = "custom_name"
        case purchaseMonth = "purchase_month"
        case usageType = "usage_type"
        case sortOrder = "sort_order"
    }

    func toPropertyInput() -> PropertyInput {
        PropertyInput(
            projectName: projectName,
            city: city,
            locality: locality,
            areaSqft: areaSqft,
            purchasePrice: purchasePrice,
            purchaseYear: purchaseYear,
            monthlyRent: monthlyRent,
            societyName: societyName,
            floorPlan: floorPlan.flatMap { FloorPlan(rawValue: $0) },
            customName: customName,
            purchaseMonth: purchaseMonth,
            usageType: usageType.flatMap { PropertyUsageType(rawValue: $0) }
        )
    }
}

/// Insert DTO — includes user_id.
private struct UserPropertyInsert: Encodable {
    let userId: String
    let projectName: String
    let city: String
    let locality: String
    let areaSqft: Int
    let purchasePrice: Int64
    let purchaseYear: Int
    let monthlyRent: Int
    let societyName: String
    let floorPlan: String?
    let customName: String
    let purchaseMonth: String
    let usageType: String?
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case projectName = "project_name"
        case city, locality
        case areaSqft = "area_sqft"
        case purchasePrice = "purchase_price"
        case purchaseYear = "purchase_year"
        case monthlyRent = "monthly_rent"
        case societyName = "society_name"
        case floorPlan = "floor_plan"
        case customName = "custom_name"
        case purchaseMonth = "purchase_month"
        case usageType = "usage_type"
        case sortOrder = "sort_order"
    }

    init(userId: String, input: PropertyInput, sortOrder: Int) {
        self.userId = userId
        self.projectName = input.projectName
        self.city = input.city
        self.locality = input.locality
        self.areaSqft = input.areaSqft
        self.purchasePrice = input.purchasePrice
        self.purchaseYear = input.purchaseYear
        self.monthlyRent = input.monthlyRent
        self.societyName = input.societyName
        self.floorPlan = input.floorPlan?.rawValue
        self.customName = input.customName
        self.purchaseMonth = input.purchaseMonth
        self.usageType = input.usageType?.rawValue
        self.sortOrder = sortOrder
    }
}

/// Update DTO — no user_id (filtered in WHERE clause).
private struct UserPropertyUpdate: Encodable {
    let projectName: String
    let city: String
    let locality: String
    let areaSqft: Int
    let purchasePrice: Int64
    let purchaseYear: Int
    let monthlyRent: Int
    let societyName: String
    let floorPlan: String?
    let customName: String
    let purchaseMonth: String
    let usageType: String?
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case projectName = "project_name"
        case city, locality
        case areaSqft = "area_sqft"
        case purchasePrice = "purchase_price"
        case purchaseYear = "purchase_year"
        case monthlyRent = "monthly_rent"
        case societyName = "society_name"
        case floorPlan = "floor_plan"
        case customName = "custom_name"
        case purchaseMonth = "purchase_month"
        case usageType = "usage_type"
        case sortOrder = "sort_order"
    }

    init(input: PropertyInput, sortOrder: Int) {
        self.projectName = input.projectName
        self.city = input.city
        self.locality = input.locality
        self.areaSqft = input.areaSqft
        self.purchasePrice = input.purchasePrice
        self.purchaseYear = input.purchaseYear
        self.monthlyRent = input.monthlyRent
        self.societyName = input.societyName
        self.floorPlan = input.floorPlan?.rawValue
        self.customName = input.customName
        self.purchaseMonth = input.purchaseMonth
        self.usageType = input.usageType?.rawValue
        self.sortOrder = sortOrder
    }
}
