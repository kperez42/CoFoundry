//
//  Constants.swift
//  CoFoundry
//
//  Centralized constants for the co-founder matching app
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - App Info
    enum App {
        static let name = "CoFoundry"
        static let tagline = "Find Your Perfect Co-Founder"
        static let version = "1.0.0"
    }

    // MARK: - API Configuration
    enum API {
        static let baseURL = "https://api.cofoundry.app"
        static let timeout: TimeInterval = 30
        static let retryAttempts = 3
    }

    // MARK: - Content Limits
    enum Limits {
        static let maxBioLength = 500
        static let maxMessageLength = 1000
        static let maxConnectionMessage = 300
        static let maxSkills = 15
        static let maxIndustries = 10
        static let maxLanguages = 5
        static let maxPhotos = 6
        static let minAge = 18
        static let maxAge = 99
        static let minPasswordLength = 8
        static let maxNameLength = 50
        static let maxProfessionalTitleLength = 100
        static let maxLinkedInURLLength = 200
    }

    // MARK: - Pagination
    enum Pagination {
        static let usersPerPage = 20
        static let messagesPerPage = 50
        static let matchesPerPage = 30
        static let connectionsPerPage = 20
    }

    // MARK: - Premium Pricing
    enum Premium {
        static let monthlyPrice = 29.99
        static let sixMonthPrice = 149.99
        static let yearlyPrice = 199.99

        // Features
        static let freeConnectionsPerDay = 10
        static let premiumUnlimitedConnections = true
        static let premiumSeeWhoConnected = true
        static let premiumBoostProfile = true
        static let premiumAdvancedFilters = true
    }

    // MARK: - Colors
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.indigo
        static let accent = Color.green
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        static let gradientStart = Color.blue
        static let gradientEnd = Color.indigo

        static func primaryGradient() -> LinearGradient {
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func accentGradient() -> LinearGradient {
            LinearGradient(
                colors: [Color.blue, Color.green],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    // MARK: - Animation Durations
    enum Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let splash: TimeInterval = 2.0
    }

    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 10
        static let largeCornerRadius: CGFloat = 20
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
    }

    // MARK: - Image Sizes
    enum ImageSize {
        static let thumbnail: CGFloat = 50
        static let small: CGFloat = 70
        static let medium: CGFloat = 100
        static let large: CGFloat = 150
        static let profile: CGFloat = 130
        static let hero: CGFloat = 400
    }

    // MARK: - Feature Flags
    enum Features {
        static let videoCallsEnabled = true
        static let calendarIntegrationEnabled = false
        static let nDAGeneratorEnabled = false
        static let pitchDeckSharingEnabled = true
        static let linkedInImportEnabled = true
        static let locationTrackingEnabled = true
    }

    // MARK: - Firebase Collections
    enum Collections {
        static let users = "users"
        static let matches = "matches"
        static let messages = "messages"
        static let connections = "connections"
        static let reports = "reports"
        static let blockedUsers = "blocked_users"
        static let analytics = "analytics"
    }

    // MARK: - Storage Paths
    enum StoragePaths {
        static let profileImages = "profile_images"
        static let chatImages = "chat_images"
        static let userPhotos = "user_photos"
        static let pitchDecks = "pitch_decks"
        static let documents = "documents"
    }

    // MARK: - Rate Limiting
    enum RateLimit {
        static let messageInterval: TimeInterval = 0.5
        static let connectionInterval: TimeInterval = 1.0
        static let searchInterval: TimeInterval = 0.3
        static let maxMessagesPerMinute = 30
        static let maxConnectionsPerDay = 10 // Free users, premium unlimited
        static let maxDailyMessagesForFreeUsers = 20
    }

    // MARK: - Cache
    enum Cache {
        static let maxImageCacheSize = 100
        static let imageCacheDuration: TimeInterval = 3600 // 1 hour
        static let userDataCacheDuration: TimeInterval = 300 // 5 minutes
    }

    // MARK: - Notifications
    enum Notifications {
        static let newMatchTitle = "New Connection!"
        static let newMessageTitle = "New Message"
        static let newConnectionTitle = "Someone wants to connect!"
    }

    // MARK: - Analytics Events
    enum AnalyticsEvents {
        static let appLaunched = "app_launched"
        static let userSignedUp = "user_signed_up"
        static let userSignedIn = "user_signed_in"
        static let profileViewed = "profile_viewed"
        static let matchCreated = "match_created"
        static let messageSent = "message_sent"
        static let connectionSent = "connection_sent"
        static let connectionAccepted = "connection_accepted"
        static let profileEdited = "profile_edited"
        static let premiumViewed = "premium_viewed"
        static let premiumPurchased = "premium_purchased"
    }

    // MARK: - Error Messages
    enum ErrorMessages {
        static let networkError = "Please check your internet connection and try again."
        static let genericError = "Something went wrong. Please try again."
        static let authError = "Authentication failed. Please try again."
        static let invalidEmail = "Please enter a valid email address."
        static let weakPassword = "Password must be at least 8 characters with numbers and letters."
        static let passwordMismatch = "Passwords do not match."
        static let accountNotFound = "No account found with this email."
        static let emailInUse = "This email is already registered."
        static let invalidAge = "You must be at least 18 years old."
        static let bioTooLong = "Bio must be less than 500 characters."
        static let messageTooLong = "Message must be less than 1000 characters."
    }

    // MARK: - URLs
    enum URLs {
        static let privacyPolicy = "https://cofoundry.app/privacy"
        static let termsOfService = "https://cofoundry.app/terms"
        static let support = "mailto:support@cofoundry.app"
        static let website = "https://cofoundry.app"
        static let linkedInURL = "https://linkedin.com/company/cofoundry"
        static let twitterURL = "https://twitter.com/cofoundry"
    }

    // MARK: - Professional Categories
    enum Professional {
        static let roleTypes = [
            "Technical Co-Founder",
            "Business Co-Founder",
            "Product Co-Founder",
            "Design Co-Founder",
            "Marketing Co-Founder",
            "Operations Co-Founder"
        ]

        static let startupStages = [
            "Idea Stage",
            "MVP Building",
            "MVP Complete",
            "Early Traction",
            "Pre-Seed",
            "Seed Funded",
            "Series A+",
            "Scaling"
        ]

        static let timeCommitments = [
            "Full-time",
            "Part-time",
            "Nights & Weekends",
            "Flexible"
        ]

        static let equityExpectations = [
            "Equal Split (50/50)",
            "Negotiable",
            "Based on Contribution",
            "Vesting Schedule",
            "Flexible"
        ]

        static let locationPreferences = [
            "Remote",
            "Local Only",
            "Hybrid",
            "Open to Relocation"
        ]
    }

    // MARK: - Debug
    enum Debug {
        #if DEBUG
        static let loggingEnabled = true
        static let showDebugInfo = true
        #else
        static let loggingEnabled = false
        static let showDebugInfo = false
        #endif
    }
}

// MARK: - Convenience Extensions

extension AppConstants {
    static func log(_ message: String, category: String = "General") {
        if Debug.loggingEnabled {
            print("[\(category)] \(message)")
        }
    }

    static func logError(_ error: Error, context: String = "") {
        if Debug.loggingEnabled {
            print("[\(context)] Error: \(error.localizedDescription)")
        }
    }
}
