import Foundation

/// Static location suggestions for the property onboarding form.
enum LocationData {

    static let cities = [
        "Ghaziabad", "Noida", "Greater Noida", "Gurugram", "Faridabad",
        "Delhi", "New Delhi", "Mumbai", "Navi Mumbai", "Thane",
        "Pune", "Bengaluru", "Hyderabad", "Chennai", "Kolkata",
        "Ahmedabad", "Jaipur", "Lucknow", "Chandigarh", "Indore",
    ]

    private static let localities: [String: [String]] = [
        "Ghaziabad": ["Raj Nagar Extension", "Indirapuram", "Vaishali", "Crossing Republik", "Vasundhra", "Kaushambi"],
        "Noida": ["Sector 62", "Sector 150", "Sector 137", "Sector 75", "Sector 44", "Sector 128", "Sector 118", "Sector 50"],
        "Greater Noida": ["Sector Alpha", "Sector Beta", "Pari Chowk", "Knowledge Park", "Techzone 4", "Yamuna Expressway"],
        "Gurugram": ["DLF Phase 5", "Sector 49", "Sector 56", "Golf Course Road", "Sohna Road", "MG Road", "Sector 82"],
        "Faridabad": ["Sector 86", "Sector 88", "Ballabgarh", "NIT", "Greater Faridabad"],
        "Delhi": ["Lajpat Nagar", "Dwarka", "Rohini", "Saket", "Vasant Kunj", "Janakpuri", "Pitampura"],
        "New Delhi": ["Connaught Place", "Chanakyapuri", "Lutyens Delhi", "Karol Bagh"],
        "Mumbai": ["Andheri West", "Andheri East", "Bandra West", "Powai", "Goregaon", "Malad West", "Worli"],
        "Navi Mumbai": ["Kharghar", "Vashi", "Panvel", "Airoli", "Belapur"],
        "Thane": ["Ghodbunder Road", "Majiwada", "Pokhran Road", "Kolshet Road"],
        "Pune": ["Wakad", "Hinjewadi", "Baner", "Kharadi", "Viman Nagar", "Hadapsar", "Koregaon Park"],
        "Bengaluru": ["Whitefield", "Koramangala", "HSR Layout", "Sarjapur Road", "Electronic City", "Indiranagar"],
        "Hyderabad": ["Gachibowli", "HITEC City", "Kondapur", "Madhapur", "Banjara Hills", "Jubilee Hills"],
        "Chennai": ["OMR", "Velachery", "Adyar", "Anna Nagar", "Porur", "Tambaram"],
        "Kolkata": ["Salt Lake", "Rajarhat", "New Town", "EM Bypass", "Alipore", "Park Street"],
        "Ahmedabad": ["SG Highway", "Prahlad Nagar", "Satellite", "Bopal", "Thaltej"],
        "Jaipur": ["Malviya Nagar", "Vaishali Nagar", "Mansarovar", "C-Scheme", "Tonk Road"],
        "Lucknow": ["Gomti Nagar", "Hazratganj", "Aliganj", "Indira Nagar"],
        "Chandigarh": ["Sector 17", "Sector 35", "Sector 43", "Mohali", "Zirakpur"],
        "Indore": ["Vijay Nagar", "Palasia", "AB Road", "Super Corridor"],
    ]

    private static let societies: [String: [String]] = [
        "Raj Nagar Extension": ["ATS Pristine", "ATS Pious Headaways", "Saya Gold Avenue", "Trident Embassy", "Apex Athena"],
        "Indirapuram": ["ATS Greens", "Mahagun Moderne", "Gyan Khand", "Ahinsa Khand", "Shipra Suncity"],
        "Vaishali": ["Mahagun Manor", "Stellar Jeevan", "Saviour Park"],
        "Vasundhra": ["Saya Zenith", "Panchsheel Greens", "Mahagun Mywoods"],
        "Sector 62": ["Supertech Capetown", "Stellar IT Park", "ATS Bouquet"],
        "Sector 150": ["ATS Knightsbridge", "Godrej Palm Retreat", "Ace Parkway"],
        "Sector 137": ["Jaypee Greens Wish Town", "Prateek Wisteria", "Logix Blossom County"],
        "DLF Phase 5": ["DLF Pinnacle", "DLF Park Place", "DLF Magnolias", "DLF Camellias"],
        "Golf Course Road": ["Ireo Grand Arch", "M3M Merlin", "Tata Primanti", "DLF The Crest"],
        "Whitefield": ["Prestige Shantiniketan", "Brigade Lakefront", "Sobha Dream Acres", "Godrej Splendour"],
        "Koramangala": ["Salarpuria Sattva", "Prestige Oasis", "Raheja Residency"],
        "Powai": ["Hiranandani Gardens", "Nahar Amrit Shakti", "Raheja Vihar"],
        "Bandra West": ["Dosti Flamingos", "Rizvi Springfield", "Bandstand Tower"],
        "Gachibowli": ["My Home Bhooja", "Aparna Sarovar Grande", "Prestige High Fields"],
        "Wakad": ["Kolte Patil Life Republic", "Pride World City", "Godrej Infinity"],
    ]

    static func localitiesFor(_ city: String) -> [String] {
        localities.first { $0.key.caseInsensitiveCompare(city) == .orderedSame }?.value ?? []
    }

    static func societiesFor(_ locality: String) -> [String] {
        societies.first { $0.key.caseInsensitiveCompare(locality) == .orderedSame }?.value ?? []
    }
}
