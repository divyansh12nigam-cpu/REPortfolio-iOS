import Foundation

/// Hardcoded area sizes (sq.ft) per society per BHK configuration.
/// Source: scraped project data for Noida & Ghaziabad projects.
/// Keyed by society name → FloorPlan rawValue → sorted area sizes.
enum AreaData {

    // society name → floor plan label → [area sizes in sq.ft]
    private static let data: [String: [String: [Int]]] = [

        // ── Noida Sector 150 ────────────────────────────────────────────
        "ATS Knightsbridge": [
            "3 BHK": [1750, 1850, 2100],
            "4 BHK": [2400, 2535, 3460],
        ],
        "Godrej Palm Retreat": [
            "2 BHK": [1285],
            "3 BHK": [1550, 1690],
            "4 BHK": [2190],
        ],
        "Ace Parkway": [
            "2 BHK": [1095, 1195, 1285],
            "3 BHK": [1565, 1810],
        ],

        // ── Noida Sector 137 ────────────────────────────────────────────
        "Jaypee Greens Wish Town": [
            "2 BHK": [1050, 1150, 1285],
            "3 BHK": [1550, 1750, 1885],
            "4 BHK": [2175, 2535],
        ],
        "Prateek Wisteria": [
            "2 BHK": [1050, 1250],
            "3 BHK": [1450, 1650],
        ],
        "Logix Blossom County": [
            "2 BHK": [1065, 1350],
            "3 BHK": [1465, 1685, 1800],
        ],

        // ── Noida Sector 62 ─────────────────────────────────────────────
        "Supertech Capetown": [
            "2 BHK": [1025, 1185],
            "3 BHK": [1400, 1500, 1650],
            "4 BHK": [2150],
        ],
        "ATS Bouquet": [
            "2 BHK": [1050],
            "3 BHK": [1475, 1550],
        ],

        // ── Ghaziabad – Raj Nagar Extension ─────────────────────────────
        "ATS Pristine": [
            "2 BHK": [1050, 1300],
            "3 BHK": [1465, 1700],
        ],
        "Saya Gold Avenue": [
            "2 BHK": [1010, 1245],
            "3 BHK": [1480, 1650],
        ],
        "Trident Embassy": [
            "2 BHK": [1050, 1160],
            "3 BHK": [1395, 1550],
        ],
        "Apex Athena": [
            "2 BHK": [1005, 1250],
            "3 BHK": [1375, 1600],
        ],

        // ── Ghaziabad – Indirapuram ─────────────────────────────────────
        "ATS Greens": [
            "2 BHK": [1050, 1225],
            "3 BHK": [1565, 1700],
            "4 BHK": [2400],
        ],
        "Mahagun Moderne": [
            "2 BHK": [1060, 1200],
            "3 BHK": [1580, 1850],
        ],
        "Shipra Suncity": [
            "2 BHK": [1000, 1150],
            "3 BHK": [1380, 1600],
        ],

        // ── Ghaziabad – Vaishali ────────────────────────────────────────
        "Mahagun Manor": [
            "2 BHK": [1050, 1200],
            "3 BHK": [1450, 1650],
        ],
        "Stellar Jeevan": [
            "2 BHK": [1040, 1175],
            "3 BHK": [1430, 1580],
        ],
        "Saviour Park": [
            "2 BHK": [1050, 1250],
            "3 BHK": [1400, 1600],
        ],

        // ── Ghaziabad – Vasundhra ───────────────────────────────────────
        "Saya Zenith": [
            "2 BHK": [1045, 1220],
            "3 BHK": [1450, 1625],
        ],
        "Panchsheel Greens": [
            "2 BHK": [1015, 1135],
            "3 BHK": [1350, 1505],
        ],
        "Mahagun Mywoods": [
            "2 BHK": [935, 1085],
            "3 BHK": [1320, 1490],
        ],
    ]

    /// Area sizes for a given society and floor plan. Returns nil if no data available.
    static func areasFor(society: String, floorPlan: FloorPlan) -> [Int]? {
        guard let societyData = data.first(where: {
            $0.key.caseInsensitiveCompare(society) == .orderedSame
        })?.value else { return nil }
        let areas = societyData[floorPlan.rawValue]
        return (areas?.isEmpty == false) ? areas : nil
    }
}
