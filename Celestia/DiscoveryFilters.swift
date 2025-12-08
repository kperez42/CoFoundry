//
//  DiscoveryFilters.swift
//  CoFoundry
//
//  Discovery filter preferences for co-founder matching
//

import Foundation

@MainActor
class DiscoveryFilters: ObservableObject {
    static let shared = DiscoveryFilters()

    @Published var maxDistance: Double = 50 // miles (for local preference)
    @Published var showVerifiedOnly: Bool = false

    // Professional Filters
    @Published var selectedSkills: Set<String> = []
    @Published var selectedIndustries: Set<String> = []
    @Published var startupStages: Set<String> = []
    @Published var roleTypes: Set<String> = []
    @Published var timeCommitments: Set<String> = []
    @Published var equityExpectations: Set<String> = []
    @Published var locationPreferences: Set<String> = []

    // Experience Filters
    @Published var minYearsExperience: Int? = nil
    @Published var maxYearsExperience: Int? = nil
    @Published var educationLevels: Set<String> = []
    @Published var fundingExperiences: Set<String> = []

    // Funding Filters
    @Published var showFundedOnly: Bool = false
    @Published var investmentCapacities: Set<String> = []

    private init() {
        loadFromUserDefaults()
    }

    // MARK: - Filter Logic

    func matchesFilters(user: User, currentUserLocation: (lat: Double, lon: Double)?) -> Bool {
        // Verification filter
        if showVerifiedOnly && !user.isVerified {
            return false
        }

        // Funded filter
        if showFundedOnly && !user.currentlyFunded {
            return false
        }

        // Distance filter (only apply if location preference is Local Only)
        if locationPreferences.contains("Local Only") {
            if let currentLocation = currentUserLocation,
               let userLat = user.latitude,
               let userLon = user.longitude {
                let distance = calculateDistance(
                    from: currentLocation,
                    to: (userLat, userLon)
                )
                if distance > maxDistance {
                    return false
                }
            }
        }

        // Skills filter (if any selected, user must have at least one match)
        if !selectedSkills.isEmpty {
            let userSkills = Set(user.skills)
            if selectedSkills.intersection(userSkills).isEmpty {
                return false
            }
        }

        // Industries filter
        if !selectedIndustries.isEmpty {
            let userIndustries = Set(user.industries)
            if selectedIndustries.intersection(userIndustries).isEmpty {
                return false
            }
        }

        // Startup stage filter
        if !startupStages.isEmpty {
            if !startupStages.contains(user.startupStage) {
                return false
            }
        }

        // Role type filter
        if !roleTypes.isEmpty {
            let userRoles = Set(user.roleSeekingTypes)
            if roleTypes.intersection(userRoles).isEmpty {
                return false
            }
        }

        // Time commitment filter
        if !timeCommitments.isEmpty {
            if !timeCommitments.contains(user.timeCommitment) {
                return false
            }
        }

        // Equity expectation filter
        if !equityExpectations.isEmpty {
            if !equityExpectations.contains(user.equityExpectation) {
                return false
            }
        }

        // Location preference filter
        if !locationPreferences.isEmpty {
            if !locationPreferences.contains(user.locationPreference) {
                return false
            }
        }

        // Years of experience filter
        if let userExperience = user.yearsExperience {
            if let min = minYearsExperience, userExperience < min {
                return false
            }
            if let max = maxYearsExperience, userExperience > max {
                return false
            }
        } else {
            // If user hasn't set experience and we have experience filters, exclude them
            if minYearsExperience != nil || maxYearsExperience != nil {
                return false
            }
        }

        // Education level filter
        if !educationLevels.isEmpty {
            guard let userEducation = user.educationLevel else {
                return false
            }
            if !educationLevels.contains(userEducation) {
                return false
            }
        }

        // Funding experience filter
        if !fundingExperiences.isEmpty {
            guard let userFunding = user.fundingExperience else {
                return false
            }
            if !fundingExperiences.contains(userFunding) {
                return false
            }
        }

        // Investment capacity filter
        if !investmentCapacities.isEmpty {
            guard let userCapacity = user.investmentCapacity else {
                return false
            }
            if !investmentCapacities.contains(userCapacity) {
                return false
            }
        }

        return true
    }

    private func calculateDistance(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> Double {
        // Validate coordinates
        guard isValidLatitude(from.lat), isValidLongitude(from.lon),
              isValidLatitude(to.lat), isValidLongitude(to.lon) else {
            Logger.shared.warning("Invalid coordinates: from(\(from.lat), \(from.lon)) to(\(to.lat), \(to.lon))", category: .matching)
            return Double.infinity // Return max distance for invalid coordinates
        }

        let earthRadiusMiles = 3958.8

        let lat1 = from.lat * .pi / 180
        let lon1 = from.lon * .pi / 180
        let lat2 = to.lat * .pi / 180
        let lon2 = to.lon * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))

        let distance = earthRadiusMiles * c

        // Validate result
        guard distance.isFinite, distance >= 0 else {
            Logger.shared.warning("Invalid distance calculation result: \(distance)", category: .matching)
            return Double.infinity
        }

        return distance
    }

    private func isValidLatitude(_ lat: Double) -> Bool {
        return lat >= -90 && lat <= 90 && lat.isFinite
    }

    private func isValidLongitude(_ lon: Double) -> Bool {
        return lon >= -180 && lon <= 180 && lon.isFinite
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        UserDefaults.standard.set(maxDistance, forKey: "maxDistance")
        UserDefaults.standard.set(showVerifiedOnly, forKey: "showVerifiedOnly")
        UserDefaults.standard.set(showFundedOnly, forKey: "showFundedOnly")

        // Professional Filters
        UserDefaults.standard.set(Array(selectedSkills), forKey: "selectedSkills")
        UserDefaults.standard.set(Array(selectedIndustries), forKey: "selectedIndustries")
        UserDefaults.standard.set(Array(startupStages), forKey: "startupStages")
        UserDefaults.standard.set(Array(roleTypes), forKey: "roleTypes")
        UserDefaults.standard.set(Array(timeCommitments), forKey: "timeCommitments")
        UserDefaults.standard.set(Array(equityExpectations), forKey: "equityExpectations")
        UserDefaults.standard.set(Array(locationPreferences), forKey: "locationPreferences")

        // Experience Filters
        UserDefaults.standard.set(minYearsExperience, forKey: "minYearsExperience")
        UserDefaults.standard.set(maxYearsExperience, forKey: "maxYearsExperience")
        UserDefaults.standard.set(Array(educationLevels), forKey: "educationLevels")
        UserDefaults.standard.set(Array(fundingExperiences), forKey: "fundingExperiences")
        UserDefaults.standard.set(Array(investmentCapacities), forKey: "investmentCapacities")
    }

    private func loadFromUserDefaults() {
        if let distance = UserDefaults.standard.object(forKey: "maxDistance") as? Double {
            maxDistance = distance
        }
        showVerifiedOnly = UserDefaults.standard.bool(forKey: "showVerifiedOnly")
        showFundedOnly = UserDefaults.standard.bool(forKey: "showFundedOnly")

        // Professional Filters
        if let skills = UserDefaults.standard.array(forKey: "selectedSkills") as? [String] {
            selectedSkills = Set(skills)
        }
        if let industries = UserDefaults.standard.array(forKey: "selectedIndustries") as? [String] {
            selectedIndustries = Set(industries)
        }
        if let stages = UserDefaults.standard.array(forKey: "startupStages") as? [String] {
            startupStages = Set(stages)
        }
        if let roles = UserDefaults.standard.array(forKey: "roleTypes") as? [String] {
            roleTypes = Set(roles)
        }
        if let commitments = UserDefaults.standard.array(forKey: "timeCommitments") as? [String] {
            timeCommitments = Set(commitments)
        }
        if let expectations = UserDefaults.standard.array(forKey: "equityExpectations") as? [String] {
            equityExpectations = Set(expectations)
        }
        if let locations = UserDefaults.standard.array(forKey: "locationPreferences") as? [String] {
            locationPreferences = Set(locations)
        }

        // Experience Filters
        minYearsExperience = UserDefaults.standard.object(forKey: "minYearsExperience") as? Int
        maxYearsExperience = UserDefaults.standard.object(forKey: "maxYearsExperience") as? Int
        if let education = UserDefaults.standard.array(forKey: "educationLevels") as? [String] {
            educationLevels = Set(education)
        }
        if let funding = UserDefaults.standard.array(forKey: "fundingExperiences") as? [String] {
            fundingExperiences = Set(funding)
        }
        if let capacities = UserDefaults.standard.array(forKey: "investmentCapacities") as? [String] {
            investmentCapacities = Set(capacities)
        }
    }

    func resetFilters() {
        maxDistance = 50
        showVerifiedOnly = false
        showFundedOnly = false

        // Professional Filters
        selectedSkills.removeAll()
        selectedIndustries.removeAll()
        startupStages.removeAll()
        roleTypes.removeAll()
        timeCommitments.removeAll()
        equityExpectations.removeAll()
        locationPreferences.removeAll()

        // Experience Filters
        minYearsExperience = nil
        maxYearsExperience = nil
        educationLevels.removeAll()
        fundingExperiences.removeAll()
        investmentCapacities.removeAll()

        saveToUserDefaults()
    }

    var hasActiveFilters: Bool {
        return showVerifiedOnly || showFundedOnly ||
               !selectedSkills.isEmpty || !selectedIndustries.isEmpty ||
               !startupStages.isEmpty || !roleTypes.isEmpty ||
               !timeCommitments.isEmpty || !equityExpectations.isEmpty ||
               !locationPreferences.isEmpty ||
               minYearsExperience != nil || maxYearsExperience != nil ||
               !educationLevels.isEmpty || !fundingExperiences.isEmpty ||
               !investmentCapacities.isEmpty
    }
}

// MARK: - Filter Options

struct FilterOptions {
    static let skills = [
        // Technical
        "iOS Development", "Android Development", "Web Development", "Backend Development",
        "Full-Stack Development", "DevOps", "Cloud Architecture", "Machine Learning",
        "Data Science", "AI/ML Engineering", "Blockchain", "Cybersecurity",
        "Mobile Development", "Frontend Development", "Database Management",
        // Business
        "Product Management", "Project Management", "Business Development",
        "Sales", "Marketing", "Growth Hacking", "SEO/SEM", "Content Marketing",
        "Social Media Marketing", "Brand Strategy", "Public Relations",
        // Design
        "UI/UX Design", "Product Design", "Graphic Design", "Brand Design",
        "Motion Design", "User Research",
        // Operations & Finance
        "Operations", "Finance", "Accounting", "Legal", "HR",
        "Supply Chain", "Customer Success", "Strategy"
    ]

    static let industries = [
        "Fintech", "Healthtech", "Edtech", "E-commerce", "SaaS", "Marketplace",
        "Consumer Apps", "Enterprise Software", "AI/ML", "Blockchain/Crypto",
        "Gaming", "Media & Entertainment", "Real Estate Tech", "Foodtech",
        "Traveltech", "Cleantech", "Biotech", "Hardware", "IoT",
        "Cybersecurity", "HR Tech", "Legal Tech", "Insurtech", "Agritech",
        "Logistics", "Social Impact", "B2B Services", "B2C Services"
    ]

    static let startupStages = [
        "Idea Stage", "MVP Building", "MVP Complete", "Early Traction",
        "Pre-Seed", "Seed Funded", "Series A+", "Scaling"
    ]

    static let roleTypes = [
        "Technical Co-Founder", "Business Co-Founder", "Product Co-Founder",
        "Design Co-Founder", "Marketing Co-Founder", "Operations Co-Founder",
        "Any Role"
    ]

    static let timeCommitments = [
        "Full-time", "Part-time", "Nights & Weekends", "Flexible"
    ]

    static let equityExpectations = [
        "Equal Split (50/50)", "Negotiable", "Based on Contribution",
        "Vesting Schedule", "Flexible"
    ]

    static let locationPreferences = [
        "Remote", "Local Only", "Hybrid", "Open to Relocation"
    ]

    static let fundingExperiences = [
        "None", "Bootstrapped", "Angel Funded", "Pre-Seed",
        "Seed", "Series A+", "Accelerator/Incubator"
    ]

    static let investmentCapacities = [
        "None", "$1K - $10K", "$10K - $50K", "$50K - $100K", "$100K+"
    ]

    static let educationLevels = [
        "High School", "Some College", "Associate's Degree",
        "Bachelor's Degree", "Master's Degree", "MBA", "PhD", "Bootcamp Graduate"
    ]
}
