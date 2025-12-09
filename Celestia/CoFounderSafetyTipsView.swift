//
//  CoFounderSafetyTipsView.swift
//  CoFoundry
//
//  Safety tips and resources for professional co-founder networking
//

import SwiftUI

struct CoFounderSafetyTipsView: View {
    @State private var selectedCategory: TipCategory = .beforeMeeting

    var body: some View {
        VStack(spacing: 0) {
            // Category Picker
            categoryPicker

            // Tips List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(SafetyTip.tips(for: selectedCategory)) { tip in
                        SafetyTipCard(tip: tip)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Networking Safety")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TipCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let category: TipCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.title)
                    .font(.caption.bold())
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Safety Tip Card

struct SafetyTipCard: View {
    let tip: SafetyTip

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tip.priority.color.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: tip.icon)
                        .font(.title3)
                        .foregroundColor(tip.priority.color)
                }

                Text(tip.title)
                    .font(.headline)

                Spacer()

                if tip.priority == .critical {
                    Text("IMPORTANT")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                }
            }

            // Description
            Text(tip.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Action items if present
            if !tip.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tip.actionItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)

                            Text(item)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(12)
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Models

enum TipCategory: CaseIterable {
    case beforeMeeting
    case firstMeeting
    case ongoingSafety
    case redFlags
    case resources

    var title: String {
        switch self {
        case .beforeMeeting: return "Before"
        case .firstMeeting: return "First Meeting"
        case .ongoingSafety: return "Ongoing"
        case .redFlags: return "Red Flags"
        case .resources: return "Resources"
        }
    }

    var icon: String {
        switch self {
        case .beforeMeeting: return "calendar.badge.clock"
        case .firstMeeting: return "hand.wave.fill"
        case .ongoingSafety: return "shield.checkered"
        case .redFlags: return "exclamationmark.triangle.fill"
        case .resources: return "link"
        }
    }
}

enum TipPriority {
    case critical
    case important
    case helpful

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .helpful: return .blue
        }
    }
}

struct SafetyTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let priority: TipPriority
    let actionItems: [String]

    static func tips(for category: TipCategory) -> [SafetyTip] {
        switch category {
        case .beforeMeeting:
            return [
                SafetyTip(
                    icon: "magnifyingglass",
                    title: "Research Their Background",
                    description: "Verify their professional background before meeting. Check LinkedIn, previous companies, and any public information.",
                    priority: .critical,
                    actionItems: [
                        "Review their LinkedIn profile thoroughly",
                        "Verify their work history and claims",
                        "Search for any news articles or press mentions"
                    ]
                ),
                SafetyTip(
                    icon: "video.fill",
                    title: "Video Call First",
                    description: "Always have at least one video call before meeting in person. This helps verify identity and assess chemistry.",
                    priority: .important,
                    actionItems: [
                        "Schedule a 30-minute intro call",
                        "Discuss your goals and expectations",
                        "Assess communication style"
                    ]
                ),
                SafetyTip(
                    icon: "person.2.fill",
                    title: "Tell Someone Your Plans",
                    description: "Let a friend, family member, or colleague know about your meeting plans.",
                    priority: .important,
                    actionItems: [
                        "Share meeting location and time",
                        "Send the person's profile info",
                        "Set up a check-in time"
                    ]
                ),
                SafetyTip(
                    icon: "doc.text.magnifyingglass",
                    title: "Verify References",
                    description: "Ask for and check professional references before committing to any partnership.",
                    priority: .helpful,
                    actionItems: [
                        "Request 2-3 professional references",
                        "Speak with former colleagues or partners",
                        "Ask about their work style and reliability"
                    ]
                )
            ]

        case .firstMeeting:
            return [
                SafetyTip(
                    icon: "building.2.fill",
                    title: "Meet in Public",
                    description: "For first meetings, choose a professional public space like a coffee shop, coworking space, or restaurant.",
                    priority: .critical,
                    actionItems: [
                        "Choose a busy coffee shop or coworking space",
                        "Avoid private offices or homes",
                        "Meet during business hours"
                    ]
                ),
                SafetyTip(
                    icon: "car.fill",
                    title: "Arrange Your Own Transportation",
                    description: "Drive yourself or use rideshare. Don't share rides until you know them better.",
                    priority: .important,
                    actionItems: [
                        "Drive yourself or use Uber/Lyft",
                        "Keep your home address private initially",
                        "Have a backup plan to leave"
                    ]
                ),
                SafetyTip(
                    icon: "clock.fill",
                    title: "Keep Initial Meetings Short",
                    description: "First meetings should be 30-60 minutes. This keeps things professional and gives you an out if needed.",
                    priority: .helpful,
                    actionItems: [
                        "Schedule a hard stop after 1 hour",
                        "Have a follow-up meeting if it goes well",
                        "Don't feel pressured to extend"
                    ]
                ),
                SafetyTip(
                    icon: "doc.badge.ellipsis",
                    title: "Don't Sign Anything Immediately",
                    description: "Never sign legal documents, agreements, or contracts at a first meeting. Take time to review.",
                    priority: .critical,
                    actionItems: [
                        "Request copies to review later",
                        "Have a lawyer review any agreements",
                        "Don't let anyone pressure you"
                    ]
                )
            ]

        case .ongoingSafety:
            return [
                SafetyTip(
                    icon: "lock.shield.fill",
                    title: "Protect Sensitive Information",
                    description: "Don't share proprietary ideas, trade secrets, or sensitive data until proper agreements are in place.",
                    priority: .critical,
                    actionItems: [
                        "Use NDAs before sharing confidential info",
                        "Be vague about specifics initially",
                        "Protect your intellectual property"
                    ]
                ),
                SafetyTip(
                    icon: "dollarsign.circle.fill",
                    title: "Never Send Money Upfront",
                    description: "Legitimate co-founders don't ask for money to \"prove commitment\" or \"cover expenses.\"",
                    priority: .critical,
                    actionItems: [
                        "Don't wire money to people you just met",
                        "Be wary of \"investment opportunities\"",
                        "All financial arrangements should be properly documented"
                    ]
                ),
                SafetyTip(
                    icon: "doc.text.fill",
                    title: "Get Everything in Writing",
                    description: "Verbal agreements mean nothing. Document roles, equity splits, and expectations in writing.",
                    priority: .important,
                    actionItems: [
                        "Use a founder agreement template",
                        "Specify vesting schedules",
                        "Define roles and responsibilities clearly"
                    ]
                ),
                SafetyTip(
                    icon: "ear",
                    title: "Trust Your Instincts",
                    description: "If something feels off about a potential co-founder, it probably is. Trust your gut.",
                    priority: .important,
                    actionItems: [
                        "Listen to your intuition",
                        "Don't ignore red flags",
                        "It's okay to walk away"
                    ]
                )
            ]

        case .redFlags:
            return [
                SafetyTip(
                    icon: "exclamationmark.triangle.fill",
                    title: "Unrealistic Promises",
                    description: "Be wary of anyone promising guaranteed success, massive returns, or \"can't fail\" opportunities.",
                    priority: .critical,
                    actionItems: [
                        "If it sounds too good to be true, it is",
                        "Ask for specifics and evidence",
                        "Be skeptical of hype"
                    ]
                ),
                SafetyTip(
                    icon: "hourglass",
                    title: "Pressure to Commit Quickly",
                    description: "Good partners give you time to think. Anyone rushing you to decide is a red flag.",
                    priority: .critical,
                    actionItems: [
                        "Take your time on big decisions",
                        "\"Act now or lose this opportunity\" is manipulative",
                        "Trust takes time to build"
                    ]
                ),
                SafetyTip(
                    icon: "eye.slash.fill",
                    title: "Vague or Inconsistent Background",
                    description: "If their story doesn't add up or they're evasive about their past, proceed with caution.",
                    priority: .important,
                    actionItems: [
                        "Note inconsistencies in their story",
                        "Verify claims independently",
                        "Ask direct questions"
                    ]
                ),
                SafetyTip(
                    icon: "person.fill.xmark",
                    title: "Bad References or No References",
                    description: "If they can't provide references or their references give lukewarm feedback, be cautious.",
                    priority: .important,
                    actionItems: [
                        "Always check references",
                        "Ask probing questions",
                        "Trust what references don't say too"
                    ]
                ),
                SafetyTip(
                    icon: "hand.raised.fill",
                    title: "Won't Put Agreements in Writing",
                    description: "If someone refuses to document agreements properly, they're not serious about partnership.",
                    priority: .critical,
                    actionItems: [
                        "Insist on written agreements",
                        "Use standard legal documents",
                        "Walk away if they refuse"
                    ]
                )
            ]

        case .resources:
            return [
                SafetyTip(
                    icon: "doc.text.fill",
                    title: "Legal Resources",
                    description: "Use established legal templates and consult with a startup lawyer before signing agreements.",
                    priority: .important,
                    actionItems: [
                        "Y Combinator SAFE agreements",
                        "Clerky for legal documents",
                        "Local startup lawyers"
                    ]
                ),
                SafetyTip(
                    icon: "building.columns.fill",
                    title: "Background Check Services",
                    description: "Consider using professional background check services for potential co-founders.",
                    priority: .helpful,
                    actionItems: [
                        "Checkr for background checks",
                        "LinkedIn for professional verification",
                        "AngelList for startup reputation"
                    ]
                ),
                SafetyTip(
                    icon: "person.3.fill",
                    title: "Startup Communities",
                    description: "Get involved in startup communities where you can get peer feedback on potential partners.",
                    priority: .helpful,
                    actionItems: [
                        "Local startup meetups",
                        "Y Combinator Startup School",
                        "Founder Slack communities"
                    ]
                ),
                SafetyTip(
                    icon: "phone.fill",
                    title: "Report Fraud",
                    description: "If you encounter a scam or fraud, report it to protect other founders.",
                    priority: .critical,
                    actionItems: [
                        "FTC at reportfraud.ftc.gov",
                        "Your local attorney general",
                        "Report to CoFoundry support"
                    ]
                )
            ]
        }
    }
}

#Preview {
    NavigationStack {
        CoFounderSafetyTipsView()
    }
}
