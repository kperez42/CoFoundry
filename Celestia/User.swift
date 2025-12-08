//
//  User.swift
//  CoFoundry
//
//  Core user model for co-founder matching
//
//  PROFILE STATUS FLOW:
//  --------------------
//  profileStatus controls user visibility and app access:
//
//  1. "pending"   - New account awaiting admin approval (SignUpView.swift)
//                   User sees: PendingApprovalView
//                   Hidden from: Other users in Discover, Likes, Search
//
//  2. "active"    - Approved and visible to others
//                   User sees: MainTabView (full app access)
//                   Set by: AdminModerationDashboard.approveProfile()
//
//  3. "rejected"  - Rejected, user must fix issues
//                   User sees: ProfileRejectionFeedbackView
//                   Set by: AdminModerationDashboard.rejectProfile()
//                   Properties: profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions
//
//  4. "flagged"   - Under extended moderator review
//                   User sees: FlaggedAccountView
//                   Set by: AdminModerationDashboard.flagProfile()
//                   Hidden from: Other users during review
//
//  5. "suspended" - Temporarily blocked (with end date)
//                   User sees: SuspendedAccountView
//                   Properties: isSuspended, suspendedAt, suspendedUntil, suspendReason
//
//  6. "banned"    - Permanently blocked
//                   User sees: BannedAccountView
//                   Properties: isBanned, bannedAt, banReason
//
//  Routing handled by: ContentView.swift (updateAuthenticationState)
//  Filtering handled by: UserService.swift, LikesView, SavedProfilesView, etc.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    // Manual ID for test data (bypasses @DocumentID restrictions)
    // This is used when creating test users in DEBUG mode
    private var _manualId: String?

    // Computed property that returns manual ID if set, otherwise @DocumentID value
    var effectiveId: String? {
        _manualId ?? id
    }

    // Equatable implementation - compare by id
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.effectiveId == rhs.effectiveId
    }
    
    // Basic Info
    var email: String
    var fullName: String
    var age: Int
    var bio: String

    // Professional Info
    var professionalTitle: String  // e.g., "Full-Stack Engineer", "Product Manager"
    var yearsExperience: Int?
    var linkedInURL: String?
    var portfolioURL: String?
    var previousStartups: Int?

    // Skills & Expertise
    var skills: [String]  // Technical skills: Swift, Python, Product Strategy, etc.
    var industries: [String]  // Fintech, Healthtech, SaaS, etc.

    // Co-Founder Preferences
    var startupStage: String  // "Idea", "MVP", "Funded", "Scaling"
    var roleSeekingTypes: [String]  // "Technical Co-Founder", "Business Co-Founder", etc.
    var timeCommitment: String  // "Full-time", "Part-time", "Nights/Weekends"
    var equityExpectation: String  // "Equal Split", "Negotiable", "Based on Contribution"
    var lookingFor: String  // What type of co-founder they want

    // Funding & Investment
    var currentlyFunded: Bool
    var fundingExperience: String?  // "None", "Angel", "Seed", "Series A+"
    var investmentCapacity: String?  // "None", "$1K-10K", "$10K-50K", "50K+"

    // Location
    var location: String
    var country: String
    var latitude: Double?
    var longitude: Double?
    var locationPreference: String  // "Remote", "Local Only", "Hybrid"

    // Profile Details
    var languages: [String]
    var photos: [String]
    var profileImageURL: String
    
    // Timestamps
    var timestamp: Date
    var lastActive: Date
    var isOnline: Bool = false
    
    // Premium & Verification
    var isPremium: Bool
    var isVerified: Bool = false
    var premiumTier: String?
    var subscriptionExpiryDate: Date?

    // ID Verification Rejection (when ID verification is rejected)
    var idVerificationRejected: Bool = false
    var idVerificationRejectedAt: Date?
    var idVerificationRejectionReason: String?

    // Admin Access (for moderation dashboard)
    var isAdmin: Bool = false

    // Profile Status (for content moderation quarantine)
    // "pending" = new account, not shown in Discover until approved by admin
    // "active" = approved, visible to other users
    // "rejected" = rejected, user must fix issues
    // "suspended" = temporarily or permanently blocked
    // "flagged" = under review by moderators
    var profileStatus: String = "pending"
    var profileStatusReason: String?           // User-friendly message
    var profileStatusReasonCode: String?       // Machine-readable code (e.g., "no_face_photo")
    var profileStatusFixInstructions: String?  // Detailed fix instructions for user
    var profileStatusUpdatedAt: Date?

    // Suspension Info (set by admin when suspending user)
    var isSuspended: Bool = false
    var suspendedAt: Date?
    var suspendedUntil: Date?
    var suspendReason: String?

    // Ban Info (permanent ban set by admin)
    var isBanned: Bool = false
    var bannedAt: Date?
    var banReason: String?

    // Warnings (accumulated from reports)
    var warningCount: Int = 0
    var hasUnreadWarning: Bool = false         // Show warning notice to user
    var lastWarningReason: String?             // Most recent warning reason
    
    // Preferences
    var ageRangeMin: Int
    var ageRangeMax: Int
    var maxDistance: Int
    var showMeInSearch: Bool = true
    
    // Stats
    var connectionsInitiated: Int = 0
    var connectionsReceived: Int = 0
    var matchCount: Int = 0
    var profileViews: Int = 0

    // Consumables (Premium Features)
    var superLikesRemaining: Int = 0
    var boostsRemaining: Int = 0
    var rewindsRemaining: Int = 0

    // Daily Limits (Free Users)
    var likesRemainingToday: Int = 50  // Free users get 50 likes/day
    var lastLikeResetDate: Date = Date()

    // Boost Status
    var isBoostActive: Bool = false
    var boostExpiryDate: Date?

    // Notifications
    var fcmToken: String?
    var notificationsEnabled: Bool = true

    // Education & Background
    var educationLevel: String?
    var fieldOfStudy: String?  // Computer Science, Business, Design, etc.

    // Profile Prompts
    var prompts: [ProfilePrompt] = []

    // Referral System
    var referralStats: ReferralStats = ReferralStats()
    var referredByCode: String?  // Code used during signup

    // PERFORMANCE: Lowercase fields for efficient Firestore prefix matching
    // These should be updated whenever fullName/country changes
    // See: UserService.searchUsers() for usage
    var fullNameLowercase: String = ""
    var countryLowercase: String = ""
    var locationLowercase: String = ""

    // Helper computed property for backward compatibility
    var name: String {
        get { fullName }
        set { fullName = newValue }
    }

    // Update lowercase fields when main fields change
    mutating func updateSearchFields() {
        fullNameLowercase = fullName.lowercased()
        countryLowercase = country.lowercased()
        locationLowercase = location.lowercased()
    }

    // Custom encoding to handle nil values properly for Firebase
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(age, forKey: .age)
        try container.encode(bio, forKey: .bio)

        // Professional Info
        try container.encode(professionalTitle, forKey: .professionalTitle)
        try container.encodeIfPresent(yearsExperience, forKey: .yearsExperience)
        try container.encodeIfPresent(linkedInURL, forKey: .linkedInURL)
        try container.encodeIfPresent(portfolioURL, forKey: .portfolioURL)
        try container.encodeIfPresent(previousStartups, forKey: .previousStartups)

        // Skills & Expertise
        try container.encode(skills, forKey: .skills)
        try container.encode(industries, forKey: .industries)

        // Co-Founder Preferences
        try container.encode(startupStage, forKey: .startupStage)
        try container.encode(roleSeekingTypes, forKey: .roleSeekingTypes)
        try container.encode(timeCommitment, forKey: .timeCommitment)
        try container.encode(equityExpectation, forKey: .equityExpectation)
        try container.encode(lookingFor, forKey: .lookingFor)

        // Funding & Investment
        try container.encode(currentlyFunded, forKey: .currentlyFunded)
        try container.encodeIfPresent(fundingExperience, forKey: .fundingExperience)
        try container.encodeIfPresent(investmentCapacity, forKey: .investmentCapacity)

        // Location
        try container.encode(location, forKey: .location)
        try container.encode(country, forKey: .country)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encode(locationPreference, forKey: .locationPreference)

        try container.encode(languages, forKey: .languages)
        try container.encode(photos, forKey: .photos)
        try container.encode(profileImageURL, forKey: .profileImageURL)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(lastActive, forKey: .lastActive)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(isAdmin, forKey: .isAdmin)
        try container.encodeIfPresent(premiumTier, forKey: .premiumTier)
        try container.encodeIfPresent(subscriptionExpiryDate, forKey: .subscriptionExpiryDate)
        try container.encode(idVerificationRejected, forKey: .idVerificationRejected)
        try container.encodeIfPresent(idVerificationRejectedAt, forKey: .idVerificationRejectedAt)
        try container.encodeIfPresent(idVerificationRejectionReason, forKey: .idVerificationRejectionReason)
        try container.encode(profileStatus, forKey: .profileStatus)
        try container.encodeIfPresent(profileStatusReason, forKey: .profileStatusReason)
        try container.encodeIfPresent(profileStatusReasonCode, forKey: .profileStatusReasonCode)
        try container.encodeIfPresent(profileStatusFixInstructions, forKey: .profileStatusFixInstructions)
        try container.encodeIfPresent(profileStatusUpdatedAt, forKey: .profileStatusUpdatedAt)
        try container.encode(isSuspended, forKey: .isSuspended)
        try container.encodeIfPresent(suspendedAt, forKey: .suspendedAt)
        try container.encodeIfPresent(suspendedUntil, forKey: .suspendedUntil)
        try container.encodeIfPresent(suspendReason, forKey: .suspendReason)
        try container.encode(isBanned, forKey: .isBanned)
        try container.encodeIfPresent(bannedAt, forKey: .bannedAt)
        try container.encodeIfPresent(banReason, forKey: .banReason)
        try container.encode(warningCount, forKey: .warningCount)
        try container.encode(hasUnreadWarning, forKey: .hasUnreadWarning)
        try container.encodeIfPresent(lastWarningReason, forKey: .lastWarningReason)
        try container.encode(ageRangeMin, forKey: .ageRangeMin)
        try container.encode(ageRangeMax, forKey: .ageRangeMax)
        try container.encode(maxDistance, forKey: .maxDistance)
        try container.encode(showMeInSearch, forKey: .showMeInSearch)
        try container.encode(connectionsInitiated, forKey: .connectionsInitiated)
        try container.encode(connectionsReceived, forKey: .connectionsReceived)
        try container.encode(matchCount, forKey: .matchCount)
        try container.encode(profileViews, forKey: .profileViews)
        try container.encodeIfPresent(fcmToken, forKey: .fcmToken)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encodeIfPresent(educationLevel, forKey: .educationLevel)
        try container.encodeIfPresent(fieldOfStudy, forKey: .fieldOfStudy)
        try container.encode(prompts, forKey: .prompts)
        try container.encode(referralStats, forKey: .referralStats)
        try container.encodeIfPresent(referredByCode, forKey: .referredByCode)

        // Encode lowercase search fields
        try container.encode(fullNameLowercase, forKey: .fullNameLowercase)
        try container.encode(countryLowercase, forKey: .countryLowercase)
        try container.encode(locationLowercase, forKey: .locationLowercase)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email, fullName, age, bio
        case professionalTitle, yearsExperience, linkedInURL, portfolioURL, previousStartups
        case skills, industries
        case startupStage, roleSeekingTypes, timeCommitment, equityExpectation, lookingFor
        case currentlyFunded, fundingExperience, investmentCapacity
        case location, country, latitude, longitude, locationPreference
        case languages, photos, profileImageURL
        case timestamp, lastActive, isOnline
        case isPremium, isVerified, isAdmin, premiumTier, subscriptionExpiryDate
        case idVerificationRejected, idVerificationRejectedAt, idVerificationRejectionReason
        case profileStatus, profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions, profileStatusUpdatedAt
        case isSuspended, suspendedAt, suspendedUntil, suspendReason
        case isBanned, bannedAt, banReason
        case warningCount, hasUnreadWarning, lastWarningReason
        case ageRangeMin, ageRangeMax, maxDistance, showMeInSearch
        case connectionsInitiated, connectionsReceived, matchCount, profileViews
        case fcmToken, notificationsEnabled
        case educationLevel, fieldOfStudy
        case prompts
        case referralStats, referredByCode
        // Performance: Lowercase search fields
        case fullNameLowercase, countryLowercase, locationLowercase
    }
    
    // Initialize from dictionary (for legacy code)
    init(dictionary: [String: Any]) {
        let dictId = dictionary["id"] as? String
        self.id = dictId
        self._manualId = dictId  // Also set manual ID for effectiveId to work
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? dictionary["name"] as? String ?? ""
        self.age = dictionary["age"] as? Int ?? 18
        self.bio = dictionary["bio"] as? String ?? ""

        // Professional Info
        self.professionalTitle = dictionary["professionalTitle"] as? String ?? ""
        self.yearsExperience = dictionary["yearsExperience"] as? Int
        self.linkedInURL = dictionary["linkedInURL"] as? String
        self.portfolioURL = dictionary["portfolioURL"] as? String
        self.previousStartups = dictionary["previousStartups"] as? Int

        // Skills & Expertise
        self.skills = dictionary["skills"] as? [String] ?? []
        self.industries = dictionary["industries"] as? [String] ?? []

        // Co-Founder Preferences
        self.startupStage = dictionary["startupStage"] as? String ?? "Idea"
        self.roleSeekingTypes = dictionary["roleSeekingTypes"] as? [String] ?? []
        self.timeCommitment = dictionary["timeCommitment"] as? String ?? "Full-time"
        self.equityExpectation = dictionary["equityExpectation"] as? String ?? "Negotiable"
        self.lookingFor = dictionary["lookingFor"] as? String ?? "Any Co-Founder"

        // Funding & Investment
        self.currentlyFunded = dictionary["currentlyFunded"] as? Bool ?? false
        self.fundingExperience = dictionary["fundingExperience"] as? String
        self.investmentCapacity = dictionary["investmentCapacity"] as? String

        // Location
        self.location = dictionary["location"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.locationPreference = dictionary["locationPreference"] as? String ?? "Remote"

        self.languages = dictionary["languages"] as? [String] ?? []
        self.photos = dictionary["photos"] as? [String] ?? []
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""

        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }

        if let lastActive = dictionary["lastActive"] as? Timestamp {
            self.lastActive = lastActive.dateValue()
        } else {
            self.lastActive = Date()
        }

        self.isOnline = dictionary["isOnline"] as? Bool ?? false
        self.isPremium = dictionary["isPremium"] as? Bool ?? false
        self.isVerified = dictionary["isVerified"] as? Bool ?? false
        self.isAdmin = dictionary["isAdmin"] as? Bool ?? false
        self.premiumTier = dictionary["premiumTier"] as? String

        if let expiryDate = dictionary["subscriptionExpiryDate"] as? Timestamp {
            self.subscriptionExpiryDate = expiryDate.dateValue()
        }

        // ID Verification rejection info
        self.idVerificationRejected = dictionary["idVerificationRejected"] as? Bool ?? false
        if let rejectedAt = dictionary["idVerificationRejectedAt"] as? Timestamp {
            self.idVerificationRejectedAt = rejectedAt.dateValue()
        }
        self.idVerificationRejectionReason = dictionary["idVerificationRejectionReason"] as? String

        // Profile Status (for moderation quarantine)
        self.profileStatus = dictionary["profileStatus"] as? String ?? "pending"
        self.profileStatusReason = dictionary["profileStatusReason"] as? String
        self.profileStatusReasonCode = dictionary["profileStatusReasonCode"] as? String
        self.profileStatusFixInstructions = dictionary["profileStatusFixInstructions"] as? String
        if let statusUpdatedAt = dictionary["profileStatusUpdatedAt"] as? Timestamp {
            self.profileStatusUpdatedAt = statusUpdatedAt.dateValue()
        }

        // Suspension info
        self.isSuspended = dictionary["isSuspended"] as? Bool ?? false
        if let suspendedAtTs = dictionary["suspendedAt"] as? Timestamp {
            self.suspendedAt = suspendedAtTs.dateValue()
        }
        if let suspendedUntilTs = dictionary["suspendedUntil"] as? Timestamp {
            self.suspendedUntil = suspendedUntilTs.dateValue()
        }
        self.suspendReason = dictionary["suspendReason"] as? String

        self.isBanned = dictionary["isBanned"] as? Bool ?? false
        if let bannedAtTs = dictionary["bannedAt"] as? Timestamp {
            self.bannedAt = bannedAtTs.dateValue()
        }
        self.banReason = dictionary["banReason"] as? String

        // Warnings
        self.warningCount = dictionary["warningCount"] as? Int ?? 0
        self.hasUnreadWarning = dictionary["hasUnreadWarning"] as? Bool ?? false
        self.lastWarningReason = dictionary["lastWarningReason"] as? String

        self.ageRangeMin = dictionary["ageRangeMin"] as? Int ?? 18
        self.ageRangeMax = dictionary["ageRangeMax"] as? Int ?? 99
        self.maxDistance = dictionary["maxDistance"] as? Int ?? 100
        self.showMeInSearch = dictionary["showMeInSearch"] as? Bool ?? true

        self.connectionsInitiated = dictionary["connectionsInitiated"] as? Int ?? 0
        self.connectionsReceived = dictionary["connectionsReceived"] as? Int ?? 0
        self.matchCount = dictionary["matchCount"] as? Int ?? 0
        self.profileViews = dictionary["profileViews"] as? Int ?? 0

        self.fcmToken = dictionary["fcmToken"] as? String
        self.notificationsEnabled = dictionary["notificationsEnabled"] as? Bool ?? true

        // Education & Background
        self.educationLevel = dictionary["educationLevel"] as? String
        self.fieldOfStudy = dictionary["fieldOfStudy"] as? String

        // Profile Prompts
        if let promptsData = dictionary["prompts"] as? [[String: Any]] {
            self.prompts = promptsData.compactMap { promptDict in
                guard let question = promptDict["question"] as? String,
                      let answer = promptDict["answer"] as? String else {
                    return nil
                }
                let id = promptDict["id"] as? String ?? UUID().uuidString
                return ProfilePrompt(id: id, question: question, answer: answer)
            }
        } else {
            self.prompts = []
        }

        // Referral System
        if let referralStatsDict = dictionary["referralStats"] as? [String: Any] {
            self.referralStats = ReferralStats(dictionary: referralStatsDict)
        } else {
            self.referralStats = ReferralStats()
        }
        self.referredByCode = dictionary["referredByCode"] as? String

        // Initialize lowercase search fields (for backward compatibility with old data)
        self.fullNameLowercase = (dictionary["fullNameLowercase"] as? String) ?? fullName.lowercased()
        self.countryLowercase = (dictionary["countryLowercase"] as? String) ?? country.lowercased()
        self.locationLowercase = (dictionary["locationLowercase"] as? String) ?? location.lowercased()
    }
    
    // Standard initializer
    init(
        id: String? = nil,
        email: String,
        fullName: String,
        age: Int,
        professionalTitle: String = "",
        lookingFor: String = "Any Co-Founder",
        bio: String = "",
        location: String,
        country: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationPreference: String = "Remote",
        skills: [String] = [],
        industries: [String] = [],
        startupStage: String = "Idea",
        roleSeekingTypes: [String] = [],
        timeCommitment: String = "Full-time",
        equityExpectation: String = "Negotiable",
        languages: [String] = [],
        photos: [String] = [],
        profileImageURL: String = "",
        timestamp: Date = Date(),
        isPremium: Bool = false,
        isVerified: Bool = false,
        lastActive: Date = Date(),
        ageRangeMin: Int = 18,
        ageRangeMax: Int = 99,
        maxDistance: Int = 100
    ) {
        self.id = id
        self._manualId = id  // Store manual ID for test users
        self.email = email
        self.fullName = fullName
        self.age = age
        self.professionalTitle = professionalTitle
        self.lookingFor = lookingFor
        self.bio = bio
        self.location = location
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.locationPreference = locationPreference
        self.skills = skills
        self.industries = industries
        self.startupStage = startupStage
        self.roleSeekingTypes = roleSeekingTypes
        self.timeCommitment = timeCommitment
        self.equityExpectation = equityExpectation
        self.currentlyFunded = false
        self.languages = languages
        self.photos = photos
        self.profileImageURL = profileImageURL
        self.timestamp = timestamp
        self.isPremium = isPremium
        self.isVerified = isVerified
        self.lastActive = lastActive
        self.ageRangeMin = ageRangeMin
        self.ageRangeMax = ageRangeMax
        self.maxDistance = maxDistance

        // Initialize lowercase search fields
        self.fullNameLowercase = fullName.lowercased()
        self.countryLowercase = country.lowercased()
        self.locationLowercase = location.lowercased()
    }
}

// MARK: - User Factory Methods

extension User {
    /// Factory method to create a minimal User object for notifications
    /// Validates required fields before creating
    static func createMinimal(
        id: String,
        fullName: String,
        from data: [String: Any]
    ) throws -> User {
        // Validate required fields
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        guard let age = data["age"] as? Int, age >= AppConstants.Limits.minAge, age <= AppConstants.Limits.maxAge else {
            throw UserCreationError.invalidField("age", "Must be between \(AppConstants.Limits.minAge) and \(AppConstants.Limits.maxAge)")
        }

        // Create with validated data and safe defaults
        return User(
            id: id,
            email: email,
            fullName: fullName,
            age: age,
            professionalTitle: data["professionalTitle"] as? String ?? "",
            lookingFor: data["lookingFor"] as? String ?? "Any Co-Founder",
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }

    /// Factory method to create User from Firestore data with validation
    static func fromFirestore(id: String, data: [String: Any]) throws -> User {
        // Validate all required fields
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        guard let fullName = data["fullName"] as? String, !fullName.isEmpty else {
            throw UserCreationError.missingRequiredField("fullName")
        }

        guard let age = data["age"] as? Int, age >= AppConstants.Limits.minAge, age <= AppConstants.Limits.maxAge else {
            throw UserCreationError.invalidField("age", "Must be between \(AppConstants.Limits.minAge) and \(AppConstants.Limits.maxAge)")
        }

        // Create with validated data
        return User(
            id: id,
            email: email,
            fullName: fullName,
            age: age,
            professionalTitle: data["professionalTitle"] as? String ?? "",
            lookingFor: data["lookingFor"] as? String ?? "Any Co-Founder",
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }
}

// MARK: - User Creation Errors

enum UserCreationError: LocalizedError {
    case missingRequiredField(String)
    case invalidField(String, String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidField(let field, let reason):
            return "Invalid field '\(field)': \(reason)"
        }
    }
}
