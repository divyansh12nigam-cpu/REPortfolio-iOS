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
    /// When low and high round to the same display value, show a single number.
    static func formatValueRange(low: Double, high: Double) -> String {
        if high >= 10_000_000 {
            let lo = String(format: "%.1f", low / 10_000_000)
            let hi = String(format: "%.1f", high / 10_000_000)
            if lo == hi { return "₹ \(hi)Cr" }
            return "₹ \(lo) - \(hi)Cr"
        } else if high >= 100_000 {
            let lo = String(format: "%.0f", low / 100_000)
            let hi = String(format: "%.0f", high / 100_000)
            if lo == hi { return "₹ \(hi)L" }
            return "₹ \(lo) - \(hi)L"
        } else {
            let lo = String(format: "%.0f", low)
            let hi = String(format: "%.0f", high)
            if lo == hi { return "₹ \(hi)" }
            return "₹ \(lo) - \(hi)"
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

    /// Convert a number to Indian-style words (Thousand → Lakh → Crore).
    /// Returns nil for zero or empty input.
    static func numberToWords(_ value: Int64) -> String? {
        guard value > 0 else { return nil }

        let ones = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
                     "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
                     "Seventeen", "Eighteen", "Nineteen"]
        let tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"]

        func twoDigits(_ n: Int) -> String {
            if n < 20 { return ones[n] }
            let t = tens[n / 10]
            let o = ones[n % 10]
            return o.isEmpty ? t : "\(t) \(o)"
        }

        func threeDigits(_ n: Int) -> String {
            if n == 0 { return "" }
            if n < 100 { return twoDigits(n) }
            let h = ones[n / 100] + " Hundred"
            let rem = n % 100
            return rem == 0 ? h : "\(h) \(twoDigits(rem))"
        }

        var n = value
        var parts: [String] = []

        // Indian system: Crore (10^7), Lakh (10^5), Thousand (10^3), Hundred (10^2)
        let crore = n / 10_000_000; n %= 10_000_000
        let lakh  = n / 100_000;    n %= 100_000
        let thou  = n / 1_000;      n %= 1_000
        let rest  = Int(n)

        if crore > 0 { parts.append("\(threeDigits(Int(crore))) Crore") }
        if lakh > 0  { parts.append("\(twoDigits(Int(lakh))) Lakh") }
        if thou > 0  { parts.append("\(twoDigits(Int(thou))) Thousand") }
        if rest > 0  { parts.append(threeDigits(rest)) }

        return parts.joined(separator: " ")
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
