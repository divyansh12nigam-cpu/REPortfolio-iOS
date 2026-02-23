import Foundation

/// Shared INR formatting utilities — mirrors Formatters.kt
enum Formatters {

    /// Format an amount as "₹X.XX Cr", "₹X.X L", or "₹X"
    static func formatAmount(_ amount: Double) -> String {
        let a = abs(amount)
        let sign = amount < 0 ? "-" : ""
        if a >= 10_000_000 {
            return String(format: "\(sign)₹%.2f Cr", a / 10_000_000)
        } else if a >= 100_000 {
            return String(format: "\(sign)₹%.1f L", a / 100_000)
        } else {
            return String(format: "\(sign)₹%.0f", a)
        }
    }

    /// Format a low–high value range as "₹ X - YCr" or "₹ X - YL"
    static func formatValueRange(low: Double, high: Double) -> String {
        if high >= 10_000_000 {
            return String(format: "₹ %.1f - %.1fCr", low / 10_000_000, high / 10_000_000)
        } else if high >= 100_000 {
            return String(format: "₹ %.0f - %.0fL", low / 100_000, high / 100_000)
        } else {
            return String(format: "₹ %.0f - %.0f", low, high)
        }
    }

    /// Format monthly rent as "₹XX,XXX"
    static func formatRent(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.0f", amount)
        return "₹\(formatted)"
    }

    /// Round to same display precision used in card ranges
    static func roundToDisplayPrecision(_ amount: Double) -> Double {
        let a = abs(amount)
        if a >= 10_000_000 {
            return (amount / 1_000_000).rounded() * 1_000_000  // nearest 10L (0.1 Cr)
        } else if a >= 100_000 {
            return (amount / 100_000).rounded() * 100_000       // nearest 1L
        } else {
            return amount.rounded()
        }
    }
}
