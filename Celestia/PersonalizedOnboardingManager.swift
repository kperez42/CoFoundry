//
//  PersonalizedOnboardingManager.swift
//  CoFoundry
//
//  Manages personalized onboarding paths based on user goals and preferences
//  Adapts the onboarding experience to match co-founder matching intentions
//

import Foundation
import SwiftUI

/// Manages personalized onboarding experiences based on co-founder goals
@MainActor
class PersonalizedOnboardingManager: ObservableObject {

    static let shared = PersonalizedOnboardingManager()

    @Published var selectedGoal: CoFounderGoal?
    @Published var recommendedPath: OnboardingPath?
    @Published var customizations: [String: Any] = [:]

    private let userDefaultsKey = "selected_onboarding_goal"

    // MARK: - Models

    enum CoFounderGoal: String, Codable, CaseIterable {
        case findTechnicalCofounder = "find_technical_cofounder"
        case findBusinessCofounder = "find_business_cofounder"
        case joinAsCofounder = "join_as_cofounder"
        case findAdvisorMentor = "find_advisor_mentor"
        case exploreOpportunities = "explore_opportunities"

        var displayName: String {
            switch self {
            case .findTechnicalCofounder: return "Find a Technical Co-founder"
            case .findBusinessCofounder: return "Find a Business Co-founder"
            case .joinAsCofounder: return "Join a Startup as Co-founder"
            case .findAdvisorMentor: return "Find Advisors & Mentors"
            case .exploreOpportunities: return "Explore Opportunities"
            }
        }

        var icon: String {
            switch self {
            case .findTechnicalCofounder: return "laptopcomputer"
            case .findBusinessCofounder: return "briefcase.fill"
            case .joinAsCofounder: return "person.badge.plus"
            case .findAdvisorMentor: return "lightbulb.fill"
            case .exploreOpportunities: return "safari.fill"
            }
        }

        var description: String {
            switch self {
            case .findTechnicalCofounder:
                return "Looking for an engineer to build your product"
            case .findBusinessCofounder:
                return "Looking for someone to handle business & operations"
            case .joinAsCofounder:
                return "Ready to join an existing startup team"
            case .findAdvisorMentor:
                return "Seeking experienced guidance for your journey"
            case .exploreOpportunities:
                return "Open to various co-founder opportunities"
            }
        }

        var color: Color {
            switch self {
            case .findTechnicalCofounder: return .blue
            case .findBusinessCofounder: return .purple
            case .joinAsCofounder: return .green
            case .findAdvisorMentor: return .orange
            case .exploreOpportunities: return .teal
            }
        }
    }

    struct OnboardingPath {
        let goal: CoFounderGoal
        let steps: [OnboardingPathStep]
        let focusAreas: [FocusArea]
        let recommendedFeatures: [String]
        let tutorialPriority: [String] // Tutorial IDs in priority order

        enum FocusArea: String {
            case profileDepth = "profile_depth"
            case photoQuality = "photo_quality"
            case bioOptimization = "bio_optimization"
            case interestMatching = "interest_matching"
            case locationAccuracy = "location_accuracy"
            case verificationTrust = "verification_trust"
        }
    }

    struct OnboardingPathStep {
        let id: String
        let title: String
        let description: String
        let importance: StepImportance
        let tips: [String]

        enum StepImportance {
            case critical
            case recommended
            case optional
        }
    }

    // MARK: - Initialization

    init() {
        loadSavedGoal()
    }

    // MARK: - Goal Selection

    func selectGoal(_ goal: CoFounderGoal) {
        selectedGoal = goal
        recommendedPath = generatePath(for: goal)
        saveGoal()

        // Track analytics
        AnalyticsManager.shared.logEvent(.onboardingStepCompleted, parameters: [
            "step": "goal_selection",
            "goal": goal.rawValue,
            "goal_name": goal.displayName
        ])

        Logger.shared.info("User selected onboarding goal: \(goal.displayName)", category: .onboarding)
    }

    // MARK: - Path Generation

    private func generatePath(for goal: CoFounderGoal) -> OnboardingPath {
        switch goal {
        case .findTechnicalCofounder:
            return createFindTechnicalCofounderPath()
        case .findBusinessCofounder:
            return createFindBusinessCofounderPath()
        case .joinAsCofounder:
            return createJoinAsCofounderPath()
        case .findAdvisorMentor:
            return createFindAdvisorPath()
        case .exploreOpportunities:
            return createExplorePath()
        }
    }

    private func createFindTechnicalCofounderPath() -> OnboardingPath {
        OnboardingPath(
            goal: .findTechnicalCofounder,
            steps: [
                OnboardingPathStep(
                    id: "founder_profile",
                    title: "Create Your Founder Profile",
                    description: "Share your startup idea, skills, and what you're building",
                    importance: .critical,
                    tips: [
                        "Clearly describe your startup idea or vision",
                        "Highlight your business/domain expertise",
                        "Be specific about what technical skills you need"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_profile",
                    title: "Verify Your Profile",
                    description: "Build trust with verified credentials",
                    importance: .critical,
                    tips: [
                        "Verified profiles get 3x more co-founder interest",
                        "Add your LinkedIn for professional credibility",
                        "Verification shows you're serious about building"
                    ]
                ),
                OnboardingPathStep(
                    id: "equity_commitment",
                    title: "Define Partnership Terms",
                    description: "Set expectations for equity and commitment",
                    importance: .recommended,
                    tips: [
                        "Be transparent about equity split expectations",
                        "Specify required time commitment (full-time/part-time)",
                        "Mention if you have funding or bootstrapping"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .bioOptimization, .interestMatching],
            recommendedFeatures: ["Skills Matching", "Industry Filters", "LinkedIn Integration"],
            tutorialPriority: ["profile_quality", "matching", "messaging", "filters"]
        )
    }

    private func createFindBusinessCofounderPath() -> OnboardingPath {
        OnboardingPath(
            goal: .findBusinessCofounder,
            steps: [
                OnboardingPathStep(
                    id: "technical_profile",
                    title: "Showcase Your Technical Skills",
                    description: "Highlight what you can build and your experience",
                    importance: .critical,
                    tips: [
                        "List your technical skills and expertise",
                        "Share projects or products you've built",
                        "Link your GitHub or portfolio"
                    ]
                ),
                OnboardingPathStep(
                    id: "idea_stage",
                    title: "Share Your Startup Stage",
                    description: "Let potential co-founders know where you are",
                    importance: .critical,
                    tips: [
                        "Describe your idea or current product",
                        "Share traction or validation if you have it",
                        "Be clear about what stage you're at"
                    ]
                ),
                OnboardingPathStep(
                    id: "cofounder_needs",
                    title: "Define What You're Looking For",
                    description: "Specify the business skills you need",
                    importance: .recommended,
                    tips: [
                        "Operations, sales, marketing, or finance?",
                        "Industry expertise requirements",
                        "Time commitment expectations"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .bioOptimization],
            recommendedFeatures: ["Skills Matching", "Startup Stage Filter", "Experience Verification"],
            tutorialPriority: ["profile_quality", "matching", "messaging", "filters"]
        )
    }

    private func createJoinAsCofounderPath() -> OnboardingPath {
        OnboardingPath(
            goal: .joinAsCofounder,
            steps: [
                OnboardingPathStep(
                    id: "skills_profile",
                    title: "Highlight Your Skills & Experience",
                    description: "Show what you bring to a founding team",
                    importance: .critical,
                    tips: [
                        "List all relevant skills and expertise",
                        "Share your professional background",
                        "Highlight any startup experience"
                    ]
                ),
                OnboardingPathStep(
                    id: "preferences",
                    title: "Set Your Preferences",
                    description: "Filter opportunities that match your interests",
                    importance: .critical,
                    tips: [
                        "Choose industries you're passionate about",
                        "Set your preferred startup stage",
                        "Define your time commitment availability"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_credentials",
                    title: "Verify Your Credentials",
                    description: "Stand out with verified experience",
                    importance: .recommended,
                    tips: [
                        "Connect LinkedIn for instant verification",
                        "Verified candidates get 2x more interest",
                        "Shows founders you're serious"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .locationAccuracy],
            recommendedFeatures: ["Industry Filters", "Stage Preferences", "Commitment Settings"],
            tutorialPriority: ["profile_quality", "filters", "matching", "messaging"]
        )
    }

    private func createFindAdvisorPath() -> OnboardingPath {
        OnboardingPath(
            goal: .findAdvisorMentor,
            steps: [
                OnboardingPathStep(
                    id: "founder_journey",
                    title: "Share Your Founder Journey",
                    description: "Help advisors understand where you need guidance",
                    importance: .critical,
                    tips: [
                        "Describe your startup and current challenges",
                        "Be specific about areas where you need help",
                        "Share your background and what you've tried"
                    ]
                ),
                OnboardingPathStep(
                    id: "advisor_needs",
                    title: "Define Advisor Criteria",
                    description: "Find mentors with relevant experience",
                    importance: .recommended,
                    tips: [
                        "Industry experience requirements",
                        "Specific skill areas (fundraising, product, etc.)",
                        "Time commitment expectations"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .bioOptimization, .interestMatching],
            recommendedFeatures: ["Experience Filter", "Industry Matching", "Advisor Mode"],
            tutorialPriority: ["profile_quality", "matching", "messaging"]
        )
    }

    private func createExplorePath() -> OnboardingPath {
        OnboardingPath(
            goal: .exploreOpportunities,
            steps: [
                OnboardingPathStep(
                    id: "basic_profile",
                    title: "Create Your Founder Profile",
                    description: "Start with the basics and explore from there",
                    importance: .critical,
                    tips: [
                        "Add a professional photo",
                        "Write a brief bio about your background",
                        "Select your skills and interests"
                    ]
                ),
                OnboardingPathStep(
                    id: "explore",
                    title: "Start Exploring",
                    description: "Discover co-founders and opportunities",
                    importance: .recommended,
                    tips: [
                        "Browse different founder profiles",
                        "You can always update your preferences later",
                        "Connect with founders who share your vision"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .bioOptimization, .interestMatching],
            recommendedFeatures: ["Discovery", "Filters", "Profile Insights"],
            tutorialPriority: ["welcome", "discovery", "matching", "messaging", "profile_quality"]
        )
    }

    // MARK: - Customizations

    func getCustomTips() -> [String] {
        guard let path = recommendedPath else { return [] }
        return path.steps.flatMap { $0.tips }
    }

    func shouldEmphasize(focusArea: OnboardingPath.FocusArea) -> Bool {
        guard let path = recommendedPath else { return false }
        return path.focusAreas.contains(focusArea)
    }

    func getPrioritizedTutorials() -> [String] {
        guard let path = recommendedPath else {
            return ["welcome", "scrolling", "matching", "messaging"]
        }
        return path.tutorialPriority
    }

    func getRecommendedFeatures() -> [String] {
        return recommendedPath?.recommendedFeatures ?? []
    }

    // MARK: - Persistence

    private func saveGoal() {
        if let goal = selectedGoal,
           let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedGoal() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let goal = try? JSONDecoder().decode(CoFounderGoal.self, from: data) {
            selectedGoal = goal
            recommendedPath = generatePath(for: goal)
        }
    }
}

// MARK: - SwiftUI View for Goal Selection

struct OnboardingGoalSelectionView: View {
    @ObservedObject var manager = PersonalizedOnboardingManager.shared
    @Environment(\.dismiss) var dismiss

    let onGoalSelected: (PersonalizedOnboardingManager.CoFounderGoal) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("What's your goal?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Help us match you with the right co-founders")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Goal Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PersonalizedOnboardingManager.CoFounderGoal.allCases, id: \.self) { goal in
                        GoalCard(goal: goal, isSelected: manager.selectedGoal == goal) {
                            withAnimation(.spring(response: 0.3)) {
                                manager.selectGoal(goal)
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                .padding(24)
            }

            // Continue Button
            if manager.selectedGoal != nil {
                Button {
                    if let goal = manager.selectedGoal {
                        onGoalSelected(goal)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct GoalCard: View {
    let goal: PersonalizedOnboardingManager.CoFounderGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(goal.color.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: goal.icon)
                            .font(.title2)
                            .foregroundColor(goal.color)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? goal.color : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? goal.color.opacity(0.2) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingGoalSelectionView { goal in
        print("Selected goal: \(goal.displayName)")
    }
}
