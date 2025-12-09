//
//  FilterModels.swift
//  CoFoundry
//
//  Data models for advanced search and filtering for co-founder matching
//

import Foundation
import CoreLocation

// MARK: - Search Filter

struct SearchFilter: Codable, Equatable {

    // MARK: - Location
    var distanceRadius: Int = 50 // miles (1-100)
    var location: CLLocationCoordinate2D?
    var useCurrentLocation: Bool = true

    // MARK: - Basic Demographics
    var ageRange: AgeRange = AgeRange(min: 18, max: 99)
    var experienceRange: ExperienceRange? // Optional years of professional experience
    var heightRange: HeightRange? // Optional height filter
    var gender: GenderFilter = .all
    var showMe: ShowMeFilter = .everyone

    // MARK: - Background
    var educationLevels: [EducationLevel] = []
    var ethnicities: [Ethnicity] = []
    var religions: [Religion] = []
    var languages: [Language] = []

    // MARK: - Professional Background
    var yearsExperienceMin: Int? // Minimum years of experience
    var yearsExperienceMax: Int? // Maximum years of experience
    var previousStartupsMin: Int? // Minimum previous startup experience

    // MARK: - Co-Founder Matching
    var startupGoals: [StartupGoal] = []
    var skillsOffered: [SkillSet] = []
    var skillsSeeking: [SkillSet] = []
    var industries: [Industry] = []
    var startupStages: [StartupStage] = []
    var commitmentLevels: [Commitment] = []
    var equityExpectations: [EquityExpectation] = []
    var relationshipGoals: [RelationshipGoal] = [] // Dating-style relationship preferences

    // MARK: - Location Preferences
    var locationPreference: LocationPreference = .any
    var hasRemoteExperience: LifestyleFilter = .any

    // MARK: - Preferences
    var verifiedOnly: Bool = false
    var withPhotosOnly: Bool = true
    var activeInLastDays: Int? // nil = any, or 1, 7, 30
    var newUsers: Bool = false // Joined in last 30 days

    // MARK: - Funding & Investment
    var fundingExperience: [FundingExperience] = []
    var currentlyFunded: LifestyleFilter = .any

    // MARK: - Metadata
    var id: String = UUID().uuidString
    var createdAt: Date = Date()
    var lastUsed: Date = Date()

    // MARK: - Helper Methods

    /// Check if filter is default (no custom filtering)
    var isDefault: Bool {
        return distanceRadius == 50 &&
               ageRange.min == 18 &&
               ageRange.max == 99 &&
               educationLevels.isEmpty &&
               startupGoals.isEmpty &&
               skillsOffered.isEmpty &&
               skillsSeeking.isEmpty &&
               industries.isEmpty &&
               startupStages.isEmpty &&
               commitmentLevels.isEmpty &&
               locationPreference == .any &&
               !verifiedOnly
    }

    /// Count active filters
    var activeFilterCount: Int {
        var count = 0

        if distanceRadius != 50 { count += 1 }
        if ageRange.min != 18 || ageRange.max != 99 { count += 1 }
        if heightRange != nil { count += 1 }
        if !educationLevels.isEmpty { count += 1 }
        if yearsExperienceMin != nil || yearsExperienceMax != nil { count += 1 }
        if previousStartupsMin != nil { count += 1 }
        if !startupGoals.isEmpty { count += 1 }
        if !skillsOffered.isEmpty { count += 1 }
        if !skillsSeeking.isEmpty { count += 1 }
        if !industries.isEmpty { count += 1 }
        if !startupStages.isEmpty { count += 1 }
        if !commitmentLevels.isEmpty { count += 1 }
        if !relationshipGoals.isEmpty { count += 1 }
        if locationPreference != .any { count += 1 }
        if !fundingExperience.isEmpty { count += 1 }
        if currentlyFunded != .any { count += 1 }
        if verifiedOnly { count += 1 }
        if activeInLastDays != nil { count += 1 }
        if newUsers { count += 1 }

        return count
    }

    /// Reset to default
    mutating func reset() {
        self = SearchFilter()
    }
}

// MARK: - Age Range

struct AgeRange: Codable, Equatable {
    var min: Int // 18-99
    var max: Int // 18-99

    init(min: Int = 18, max: Int = 99) {
        self.min = Swift.max(18, Swift.min(99, min))
        self.max = Swift.max(18, Swift.min(99, max))
    }

    func contains(_ age: Int) -> Bool {
        return age >= min && age <= max
    }
}

// MARK: - Experience Range (Years)

struct ExperienceRange: Codable, Equatable {
    var min: Int // 0-50 years
    var max: Int

    init(min: Int = 0, max: Int = 50) {
        self.min = Swift.max(0, Swift.min(50, min))
        self.max = Swift.max(0, Swift.min(50, max))
    }

    func contains(_ years: Int) -> Bool {
        return years >= min && years <= max
    }
}

// MARK: - Height Range (for filtering by height)

struct HeightRange: Codable, Equatable {
    var minInches: Int // 48-96 inches (4'0" to 8'0")
    var maxInches: Int

    init(minInches: Int = 48, maxInches: Int = 96) {
        self.minInches = Swift.max(48, Swift.min(96, minInches))
        self.maxInches = Swift.max(48, Swift.min(96, maxInches))
    }

    func contains(_ heightInInches: Int) -> Bool {
        return heightInInches >= minInches && heightInInches <= maxInches
    }

    /// Format height in inches to feet/inches display string
    static func formatHeight(_ heightInInches: Int) -> String {
        let feet = heightInInches / 12
        let inches = heightInInches % 12
        return "\(feet)'\(inches)\""
    }

    /// Convert centimeters to inches
    static func cmToInches(_ cm: Int) -> Int {
        return Int(Double(cm) / 2.54)
    }

    /// Convert inches to centimeters
    static func inchesToCm(_ inches: Int) -> Int {
        return Int(Double(inches) * 2.54)
    }
}

// MARK: - Gender Filter

enum GenderFilter: String, Codable, CaseIterable {
    case all = "all"
    case men = "men"
    case women = "women"
    case nonBinary = "non_binary"

    var displayName: String {
        switch self {
        case .all: return "Everyone"
        case .men: return "Men"
        case .women: return "Women"
        case .nonBinary: return "Non-Binary"
        }
    }
}

// MARK: - Show Me Filter

enum ShowMeFilter: String, Codable, CaseIterable {
    case everyone = "everyone"
    case men = "men"
    case women = "women"
    case nonBinary = "non_binary"

    var displayName: String {
        switch self {
        case .everyone: return "Everyone"
        case .men: return "Men"
        case .women: return "Women"
        case .nonBinary: return "Non-Binary"
        }
    }
}

// MARK: - Education Level

enum EducationLevel: String, Codable, CaseIterable {
    case highSchool = "high_school"
    case someCollege = "some_college"
    case bachelors = "bachelors"
    case masters = "masters"
    case doctorate = "doctorate"
    case tradeSchool = "trade_school"

    var displayName: String {
        switch self {
        case .highSchool: return "High School"
        case .someCollege: return "Some College"
        case .bachelors: return "Bachelor's Degree"
        case .masters: return "Master's Degree"
        case .doctorate: return "Doctorate"
        case .tradeSchool: return "Trade School"
        }
    }

    var icon: String {
        switch self {
        case .highSchool: return "building.2"
        case .someCollege: return "book"
        case .bachelors: return "graduationcap"
        case .masters: return "graduationcap.fill"
        case .doctorate: return "star.fill"
        case .tradeSchool: return "hammer"
        }
    }
}

// MARK: - Ethnicity

enum Ethnicity: String, Codable, CaseIterable {
    case asian = "asian"
    case black = "black"
    case hispanic = "hispanic"
    case middleEastern = "middle_eastern"
    case nativeAmerican = "native_american"
    case pacificIslander = "pacific_islander"
    case white = "white"
    case mixed = "mixed"
    case other = "other"

    var displayName: String {
        switch self {
        case .asian: return "Asian"
        case .black: return "Black / African"
        case .hispanic: return "Hispanic / Latino"
        case .middleEastern: return "Middle Eastern"
        case .nativeAmerican: return "Native American"
        case .pacificIslander: return "Pacific Islander"
        case .white: return "White / Caucasian"
        case .mixed: return "Mixed"
        case .other: return "Other"
        }
    }
}

// MARK: - Religion

enum Religion: String, Codable, CaseIterable {
    case agnostic = "agnostic"
    case atheist = "atheist"
    case buddhist = "buddhist"
    case catholic = "catholic"
    case christian = "christian"
    case hindu = "hindu"
    case jewish = "jewish"
    case muslim = "muslim"
    case spiritual = "spiritual"
    case other = "other"

    var displayName: String {
        switch self {
        case .agnostic: return "Agnostic"
        case .atheist: return "Atheist"
        case .buddhist: return "Buddhist"
        case .catholic: return "Catholic"
        case .christian: return "Christian"
        case .hindu: return "Hindu"
        case .jewish: return "Jewish"
        case .muslim: return "Muslim"
        case .spiritual: return "Spiritual"
        case .other: return "Other"
        }
    }
}

// MARK: - Language

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"
    case russian = "ru"
    case hindi = "hi"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .arabic: return "Arabic"
        case .russian: return "Russian"
        case .hindi: return "Hindi"
        }
    }
}

// MARK: - Lifestyle Filter

enum LifestyleFilter: String, Codable, CaseIterable {
    case any = "any"
    case yes = "yes"
    case no = "no"
    case sometimes = "sometimes"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .yes: return "Yes"
        case .no: return "No"
        case .sometimes: return "Sometimes"
        }
    }
}

// MARK: - Startup Goal

enum StartupGoal: String, Codable, CaseIterable {
    case findTechnicalCofounder = "find_technical_cofounder"
    case findBusinessCofounder = "find_business_cofounder"
    case findDesignCofounder = "find_design_cofounder"
    case findMarketingCofounder = "find_marketing_cofounder"
    case findInvestors = "find_investors"
    case findAdvisors = "find_advisors"
    case joinStartup = "join_startup"

    var displayName: String {
        switch self {
        case .findTechnicalCofounder: return "Find Technical Co-founder"
        case .findBusinessCofounder: return "Find Business Co-founder"
        case .findDesignCofounder: return "Find Design Co-founder"
        case .findMarketingCofounder: return "Find Marketing Co-founder"
        case .findInvestors: return "Find Investors"
        case .findAdvisors: return "Find Advisors"
        case .joinStartup: return "Join a Startup"
        }
    }

    var icon: String {
        switch self {
        case .findTechnicalCofounder: return "laptopcomputer"
        case .findBusinessCofounder: return "briefcase.fill"
        case .findDesignCofounder: return "paintbrush.fill"
        case .findMarketingCofounder: return "megaphone.fill"
        case .findInvestors: return "dollarsign.circle.fill"
        case .findAdvisors: return "lightbulb.fill"
        case .joinStartup: return "person.badge.plus"
        }
    }

    var description: String {
        switch self {
        case .findTechnicalCofounder:
            return "Looking for an engineer or developer to build the product"
        case .findBusinessCofounder:
            return "Looking for someone to handle business operations and strategy"
        case .findDesignCofounder:
            return "Looking for a designer to shape the product experience"
        case .findMarketingCofounder:
            return "Looking for someone to drive growth and marketing"
        case .findInvestors:
            return "Seeking investment for your startup"
        case .findAdvisors:
            return "Looking for experienced mentors and advisors"
        case .joinStartup:
            return "Want to join an existing startup as co-founder"
        }
    }
}

// MARK: - Skill Set

enum SkillSet: String, Codable, CaseIterable {
    case softwareEngineering = "software_engineering"
    case productManagement = "product_management"
    case design = "design"
    case marketing = "marketing"
    case sales = "sales"
    case finance = "finance"
    case operations = "operations"
    case legal = "legal"
    case dataScience = "data_science"
    case aiMl = "ai_ml"
    case hardware = "hardware"
    case biotech = "biotech"
    case blockchain = "blockchain"
    case cybersecurity = "cybersecurity"

    var displayName: String {
        switch self {
        case .softwareEngineering: return "Software Engineering"
        case .productManagement: return "Product Management"
        case .design: return "Design (UI/UX)"
        case .marketing: return "Marketing & Growth"
        case .sales: return "Sales & BD"
        case .finance: return "Finance & Accounting"
        case .operations: return "Operations"
        case .legal: return "Legal"
        case .dataScience: return "Data Science"
        case .aiMl: return "AI / Machine Learning"
        case .hardware: return "Hardware Engineering"
        case .biotech: return "Biotech / Life Sciences"
        case .blockchain: return "Blockchain / Web3"
        case .cybersecurity: return "Cybersecurity"
        }
    }

    var icon: String {
        switch self {
        case .softwareEngineering: return "chevron.left.forwardslash.chevron.right"
        case .productManagement: return "rectangle.3.group"
        case .design: return "paintpalette.fill"
        case .marketing: return "megaphone.fill"
        case .sales: return "chart.line.uptrend.xyaxis"
        case .finance: return "dollarsign.circle.fill"
        case .operations: return "gearshape.2.fill"
        case .legal: return "scale.3d"
        case .dataScience: return "chart.bar.xaxis"
        case .aiMl: return "brain.head.profile"
        case .hardware: return "cpu.fill"
        case .biotech: return "flask.fill"
        case .blockchain: return "link"
        case .cybersecurity: return "lock.shield.fill"
        }
    }
}

// MARK: - Startup Stage

enum StartupStage: String, Codable, CaseIterable {
    case idea = "idea"
    case validation = "validation"
    case mvp = "mvp"
    case preSeed = "pre_seed"
    case seed = "seed"
    case seriesA = "series_a"
    case growth = "growth"

    var displayName: String {
        switch self {
        case .idea: return "Idea Stage"
        case .validation: return "Validation"
        case .mvp: return "MVP / Building"
        case .preSeed: return "Pre-Seed"
        case .seed: return "Seed"
        case .seriesA: return "Series A"
        case .growth: return "Growth Stage"
        }
    }

    var icon: String {
        switch self {
        case .idea: return "lightbulb.fill"
        case .validation: return "checkmark.seal.fill"
        case .mvp: return "hammer.fill"
        case .preSeed: return "leaf.fill"
        case .seed: return "sprout"
        case .seriesA: return "chart.line.uptrend.xyaxis"
        case .growth: return "arrow.up.right"
        }
    }

    var description: String {
        switch self {
        case .idea: return "Just an idea, looking to validate"
        case .validation: return "Testing the market and concept"
        case .mvp: return "Building the first version"
        case .preSeed: return "Early funding, building team"
        case .seed: return "Seed funded, scaling"
        case .seriesA: return "Series A and beyond"
        case .growth: return "Established, rapid growth"
        }
    }
}

// MARK: - Industry

enum Industry: String, Codable, CaseIterable {
    case fintech = "fintech"
    case healthtech = "healthtech"
    case edtech = "edtech"
    case saas = "saas"
    case ecommerce = "ecommerce"
    case marketplace = "marketplace"
    case socialMedia = "social_media"
    case gaming = "gaming"
    case climatetech = "climatetech"
    case biotech = "biotech"
    case hardware = "hardware"
    case ai = "ai"

    var displayName: String {
        switch self {
        case .fintech: return "Fintech"
        case .healthtech: return "Healthtech"
        case .edtech: return "Edtech"
        case .saas: return "SaaS"
        case .ecommerce: return "E-commerce"
        case .marketplace: return "Marketplace"
        case .socialMedia: return "Social Media"
        case .gaming: return "Gaming"
        case .climatetech: return "Climatetech"
        case .biotech: return "Biotech"
        case .hardware: return "Hardware"
        case .ai: return "AI / ML"
        }
    }

    var icon: String {
        switch self {
        case .fintech: return "creditcard.fill"
        case .healthtech: return "heart.text.square.fill"
        case .edtech: return "graduationcap.fill"
        case .saas: return "cloud.fill"
        case .ecommerce: return "cart.fill"
        case .marketplace: return "storefront.fill"
        case .socialMedia: return "bubble.left.and.bubble.right.fill"
        case .gaming: return "gamecontroller.fill"
        case .climatetech: return "leaf.fill"
        case .biotech: return "flask.fill"
        case .hardware: return "cpu.fill"
        case .ai: return "brain.head.profile"
        }
    }
}

// MARK: - Commitment Level

enum Commitment: String, Codable, CaseIterable {
    case fullTime = "full_time"
    case partTime = "part_time"
    case advisor = "advisor"
    case weekendsOnly = "weekends_only"

    var displayName: String {
        switch self {
        case .fullTime: return "Full-Time"
        case .partTime: return "Part-Time"
        case .advisor: return "Advisor Role"
        case .weekendsOnly: return "Weekends Only"
        }
    }

    var icon: String {
        switch self {
        case .fullTime: return "clock.fill"
        case .partTime: return "clock"
        case .advisor: return "person.fill.questionmark"
        case .weekendsOnly: return "calendar.badge.clock"
        }
    }

    var description: String {
        switch self {
        case .fullTime: return "40+ hours/week, fully dedicated"
        case .partTime: return "20-30 hours/week"
        case .advisor: return "Strategic guidance, limited time"
        case .weekendsOnly: return "10-15 hours on weekends"
        }
    }
}

// MARK: - Equity Expectation

enum EquityExpectation: String, Codable, CaseIterable {
    case negotiable = "negotiable"
    case fiftyFifty = "fifty_fifty"
    case majorityFounder = "majority_founder"
    case minorityCofounder = "minority_cofounder"

    var displayName: String {
        switch self {
        case .negotiable: return "Negotiable"
        case .fiftyFifty: return "50/50 Split"
        case .majorityFounder: return "Majority Founder (60%+)"
        case .minorityCofounder: return "Minority Co-founder (<40%)"
        }
    }

    var icon: String {
        switch self {
        case .negotiable: return "arrow.triangle.2.circlepath"
        case .fiftyFifty: return "equal.circle.fill"
        case .majorityFounder: return "chart.pie.fill"
        case .minorityCofounder: return "chart.pie"
        }
    }
}

// MARK: - Location Preference

enum LocationPreference: String, Codable, CaseIterable {
    case any = "any"
    case remote = "remote"
    case local = "local"
    case hybrid = "hybrid"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .remote: return "Remote Only"
        case .local: return "Local / In-Person"
        case .hybrid: return "Hybrid"
        }
    }

    var icon: String {
        switch self {
        case .any: return "globe"
        case .remote: return "laptopcomputer.and.arrow.down"
        case .local: return "building.2.fill"
        case .hybrid: return "arrow.triangle.branch"
        }
    }
}

// MARK: - Funding Experience

enum FundingExperience: String, Codable, CaseIterable {
    case none = "none"
    case angel = "angel"
    case seed = "seed"
    case seriesAPlus = "series_a_plus"
    case bootstrapped = "bootstrapped"
    case exitExperience = "exit_experience"

    var displayName: String {
        switch self {
        case .none: return "No Prior Funding"
        case .angel: return "Angel Funded"
        case .seed: return "Seed Funded"
        case .seriesAPlus: return "Series A+"
        case .bootstrapped: return "Bootstrapped"
        case .exitExperience: return "Previous Exit"
        }
    }

    var icon: String {
        switch self {
        case .none: return "doc.text"
        case .angel: return "person.fill"
        case .seed: return "leaf.fill"
        case .seriesAPlus: return "chart.line.uptrend.xyaxis"
        case .bootstrapped: return "hammer.fill"
        case .exitExperience: return "star.fill"
        }
    }
}

// MARK: - Zodiac Sign

enum ZodiacSign: String, Codable, CaseIterable {
    case aries = "aries"
    case taurus = "taurus"
    case gemini = "gemini"
    case cancer = "cancer"
    case leo = "leo"
    case virgo = "virgo"
    case libra = "libra"
    case scorpio = "scorpio"
    case sagittarius = "sagittarius"
    case capricorn = "capricorn"
    case aquarius = "aquarius"
    case pisces = "pisces"

    var displayName: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }

    var icon: String {
        switch self {
        case .aries: return "flame"
        case .taurus: return "leaf.fill"
        case .gemini: return "person.2.fill"
        case .cancer: return "moon.fill"
        case .leo: return "sun.max.fill"
        case .virgo: return "leaf"
        case .libra: return "scale.3d"
        case .scorpio: return "bolt.fill"
        case .sagittarius: return "arrow.up.right"
        case .capricorn: return "mountain.2.fill"
        case .aquarius: return "drop.fill"
        case .pisces: return "fish.fill"
        }
    }

    var dateRange: String {
        switch self {
        case .aries: return "Mar 21 - Apr 19"
        case .taurus: return "Apr 20 - May 20"
        case .gemini: return "May 21 - Jun 20"
        case .cancer: return "Jun 21 - Jul 22"
        case .leo: return "Jul 23 - Aug 22"
        case .virgo: return "Aug 23 - Sep 22"
        case .libra: return "Sep 23 - Oct 22"
        case .scorpio: return "Oct 23 - Nov 21"
        case .sagittarius: return "Nov 22 - Dec 21"
        case .capricorn: return "Dec 22 - Jan 19"
        case .aquarius: return "Jan 20 - Feb 18"
        case .pisces: return "Feb 19 - Mar 20"
        }
    }
}

// MARK: - Relationship Goal

enum RelationshipGoal: String, Codable, CaseIterable {
    case longTerm = "long_term"
    case casual = "casual"
    case newFriends = "new_friends"
    case notSure = "not_sure"
    case marriage = "marriage"
    case shortTerm = "short_term"

    var displayName: String {
        switch self {
        case .longTerm: return "Long-term relationship"
        case .casual: return "Casual dating"
        case .newFriends: return "New friends"
        case .notSure: return "Not sure yet"
        case .marriage: return "Marriage"
        case .shortTerm: return "Short-term relationship"
        }
    }

    var icon: String {
        switch self {
        case .longTerm: return "heart.fill"
        case .casual: return "heart"
        case .newFriends: return "person.2.fill"
        case .notSure: return "questionmark.circle.fill"
        case .marriage: return "ring"
        case .shortTerm: return "heart.circle"
        }
    }
}

// MARK: - Filter Preset

struct FilterPreset: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var filter: SearchFilter
    var createdAt: Date
    var lastUsed: Date
    var usageCount: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        filter: SearchFilter,
        createdAt: Date = Date(),
        lastUsed: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.filter = filter
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.usageCount = usageCount
    }
}

// MARK: - Search History Entry

struct SearchHistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let filter: SearchFilter
    let timestamp: Date
    let resultsCount: Int

    init(
        id: String = UUID().uuidString,
        filter: SearchFilter,
        timestamp: Date = Date(),
        resultsCount: Int
    ) {
        self.id = id
        self.filter = filter
        self.timestamp = timestamp
        self.resultsCount = resultsCount
    }
}

// MARK: - CLLocationCoordinate2D Extension

extension CLLocationCoordinate2D: @retroactive Codable, @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }


    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
