# CoFoundry

A modern iOS co-founder matching application built with SwiftUI and Firebase, featuring swipe-based matching, real-time messaging, and premium subscriptions to help entrepreneurs find their perfect business partner.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Firebase Configuration](#firebase-configuration)
- [Architecture](#architecture)
- [Testing](#testing)
- [Premium Features](#premium-features)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Features

### Core Co-Founder Matching Features
- **Founder Discovery** - Swipe-based matching system with advanced filters (experience, skills, industry, funding stage)
- **Profile System** - Professional profiles with bio, skills, startup experience, and partnership goals
- **Matching System** - Mutual likes create instant connections
- **Real-time Messaging** - Live chat with connection tracking, unread counts, and typing indicators
- **Interests/Likes** - Send connection requests to potential co-founders with optional messages

### Advanced Features
- **Photo Verification** - Face detection using Apple's Vision framework
- **Referral System** - Users earn 7 days of premium for each successful referral
- **Profile Insights** - Analytics on profile views, swipe stats, match rates, and photo performance
- **Content Moderation** - Automatic profanity filtering, spam detection, and personal info blocking
- **Safety Center** - Safety tips for meeting co-founders, reporting, blocking, and screenshot detection
- **Profile Prompts** - 100+ questions to showcase your startup vision and work style
- **Conversation Starters** - Pre-built icebreaker messages for professional networking
- **Email Verification** - Required for full app access

### Premium Features
- Unlimited swipes (free users: 50/day limit)
- See who liked you
- Profile boosting (10x visibility)
- 5 super likes per day
- Rewind swipes
- Priority support
- Advanced analytics

## Requirements

- **iOS 16.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **CocoaPods** or **Swift Package Manager**
- **Firebase Account** (free tier works for development)
- **Apple Developer Account** (for StoreKit testing)

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/CoFoundry.git
cd CoFoundry
```

### 2. Install Dependencies

If using CocoaPods:

```bash
pod install
open CoFoundry.xcworkspace
```

If using Swift Package Manager (SPM):
- Open `CoFoundry.xcodeproj` in Xcode
- Dependencies should auto-resolve

### 3. Configure Firebase

See [Firebase Configuration](#firebase-configuration) section below for detailed setup.

### 4. Configure Signing

- Open the project in Xcode
- Select the CoFoundry target
- Go to "Signing & Capabilities"
- Select your development team
- Xcode will automatically create provisioning profiles

### 5. Run the App

- Select a simulator or connected device
- Press `Cmd + R` to build and run

## Firebase Configuration

### Prerequisites

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an iOS app to your Firebase project
3. Download `GoogleService-Info.plist`

### Setup Steps

#### 1. Add Configuration File

- Place `GoogleService-Info.plist` in the root of the Celestia Xcode project
- Make sure it's added to the CoFoundry target

#### 2. Enable Firebase Services

In the Firebase Console, enable:

**Authentication:**
- Email/Password authentication
- Configure email verification (see [FIREBASE_EMAIL_SETUP.md](./FIREBASE_EMAIL_SETUP.md))

**Firestore Database:**
- Create database in production mode
- Deploy security rules from `firestore.rules` (if provided)

**Firebase Storage:**
- Enable Storage
- Configure security rules for profile images

**Cloud Messaging (FCM):**
- Enable FCM for push notifications
- Upload APNs certificates (Development & Production)

**Analytics:**
- Automatically enabled when you add Firebase

#### 3. Firestore Collections

The app uses these Firestore collections:

```
users/
  - {userId}/
    - email, fullName, skills, partnershipGoal, etc.

matches/
  - {matchId}/
    - user1Id, user2Id, timestamp, lastMessage, etc.

messages/
  - {messageId}/
    - matchId, senderId, text, timestamp, etc.

likes/
  - {likeId}/
    - fromUserId, toUserId, isSuperLike, timestamp

passes/
  - {passId}/
    - fromUserId, toUserId, timestamp

referrals/
  - {referralId}/
    - referrerUserId, referredUserId, referralCode, status

reports/
  - {reportId}/
    - reporterId, reportedUserId, reason, timestamp
```

#### 4. Security Rules

Deploy Firestore security rules to protect user data:

```bash
firebase deploy --only firestore:rules
```

See [Firebase Documentation](https://firebase.google.com/docs/firestore/security/get-started) for more details.

### Email Verification Setup

Email verification is required for all users. See the comprehensive guide: [FIREBASE_EMAIL_SETUP.md](./FIREBASE_EMAIL_SETUP.md)

## Architecture

CoFoundry follows the **MVVM (Model-View-ViewModel)** architecture pattern with a service layer for business logic.

### Architecture Diagram

```
┌─────────────────────────────────────────┐
│           Views (SwiftUI)                │
│  - SignInView, SignUpView               │
│  - MainTabView, DiscoverView            │
│  - ProfileView, MatchesView             │
│  - MessagesView, PremiumUpgradeView     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       ViewModels (@Published)            │
│  - AuthViewModel (deprecated)            │
│  - DiscoverViewModel                     │
│  - ProfileViewModel                      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Services (Business Logic)        │
│  - AuthService                           │
│  - UserService                           │
│  - MatchService                          │
│  - MessageService                        │
│  - SwipeService                          │
│  - ReferralManager                       │
│  - StoreManager                          │
│  - NotificationService                   │
│  - ContentModerator                      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│        Data Layer (Firebase)             │
│  - Firestore Database                    │
│  - Firebase Auth                         │
│  - Firebase Storage                      │
│  - Firebase Analytics                    │
└──────────────────────────────────────────┘
```

### Key Components

#### Services

**AuthService** (`AuthService.swift:256`)
- User authentication (sign up, sign in, sign out)
- Email verification
- Password reset
- Input validation and sanitization

**MatchService** (`MatchService.swift`)
- Connection creation and management
- Real-time connection listeners
- Unread count tracking
- Connection deletion/disconnect

**SwipeService** (`SwipeService.swift`)
- Like/pass recording
- Mutual connection detection
- Super likes
- Swipe history tracking

**ReferralManager** (`ReferralManager.swift`)
- Referral code generation
- Referral tracking and rewards
- Premium days calculation
- Leaderboard management

**StoreManager** (`StoreManager.swift`)
- In-app purchases using StoreKit 2
- Subscription management
- Transaction verification
- Server-side validation (template provided)
- Firestore premium status updates

**ContentModerator** (`ContentModerator.swift`)
- Profanity detection and filtering
- Spam detection
- Personal info detection (phone, email, address)
- Content scoring

**NotificationService** (`NotificationService.swift`)
- Push notification management
- FCM token handling
- New connection/message notifications

#### Models

**User** (`User.swift:220`)
- Comprehensive user profile model
- Supports Firestore encoding/decoding
- Contains preferences, stats, and referral info

**Match** (`Match.swift`)
- Represents a connection between two users
- Tracks last message and unread counts

**Message** (`Message.swift`)
- Chat message model
- Supports text, images, and metadata

#### Utilities

**ErrorHandling** (`ErrorHandling.swift`)
- Comprehensive error types
- User-friendly error messages
- Recovery suggestions

**Constants** (`Constants.swift:233`)
- Centralized configuration
- Feature flags
- API limits and constraints

**HapticManager** (`HapticManager.swift`)
- Haptic feedback management

**AnalyticsManager** (`AnalyticsManager.swift`)
- Firebase Analytics integration
- Event tracking

### Design Patterns

1. **Singleton Pattern** - Services use shared instances
2. **Protocol-Based Design** - `ServiceProtocols.swift` defines interfaces
3. **Dependency Injection** - Ready for testing with DI
4. **Observer Pattern** - SwiftUI's `@Published` for reactive updates
5. **Strategy Pattern** - Content moderation strategies

## Testing

CoFoundry includes comprehensive unit tests for core services.

### Running Tests

```bash
# Run all tests
Command + U in Xcode

# Or via command line
xcodebuild test -workspace CoFoundry.xcworkspace -scheme CoFoundry -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage

The following services have comprehensive unit tests:

- **AuthServiceTests** - Authentication flows, validation, error handling
- **MatchServiceTests** - Connection creation, sorting, unread counts
- **ContentModeratorTests** - Profanity, spam, personal info detection
- **SwipeServiceTests** - Like/pass logic, mutual matching
- **ReferralManagerTests** - Code generation, rewards calculation

### Test Files

```
CelestiaTests/
├── AuthServiceTests.swift          (56 tests)
├── MatchServiceTests.swift         (32 tests)
├── ContentModeratorTests.swift     (45 tests)
├── SwipeServiceTests.swift         (38 tests)
└── ReferralManagerTests.swift      (41 tests)
```

### Writing New Tests

Use Swift Testing framework:

```swift
import Testing
@testable import CoFoundry

@Suite("My Feature Tests")
struct MyFeatureTests {
    @Test("Test description")
    func testFeature() async throws {
        #expect(condition, "Failure message")
    }
}
```

## Premium Features

### Subscription Tiers

| Feature | Free | Monthly | 6 Months | Annual |
|---------|------|---------|----------|--------|
| **Price** | $0 | $19.99/mo | $14.99/mo | $9.99/mo |
| **Swipes/Day** | 50 | Unlimited | Unlimited | Unlimited |
| **See Likes** | ❌ | ✅ | ✅ | ✅ |
| **Super Likes** | 1/day | 5/day | 5/day | 5/day |
| **Profile Boost** | ❌ | ✅ | ✅ | ✅ |
| **Rewind** | ❌ | ✅ | ✅ | ✅ |
| **Priority Support** | ❌ | ✅ | ✅ | ✅ |

### StoreKit 2 Implementation

CoFoundry uses StoreKit 2 for in-app purchases with:

- **Transaction Verification** - Automatic verification of purchases
- **Subscription Status** - Real-time subscription state tracking
- **Auto-Renewable Subscriptions** - Handled by Apple
- **Purchase Restoration** - Users can restore purchases on new devices
- **Grace Period Support** - Handles billing issues gracefully
- **Server Validation Template** - Ready for backend receipt validation

### Testing In-App Purchases

1. Create a Sandbox test user in App Store Connect
2. Sign out of App Store on device/simulator
3. Run the app and test purchases with sandbox account
4. Purchases are free and immediate in sandbox mode

## Project Structure

```
CoFoundry/
├── Celestia/                         # Main iOS app source
│   ├── CelestiaApp.swift             # App entry point
│   ├── ContentView.swift             # Root view with auth routing
│   │
│   ├── Models/                       # Data models
│   │   ├── User.swift                # User profile model
│   │   ├── Match.swift               # Connection model
│   │   ├── Message.swift             # Message model
│   │   └── ProfilePrompt.swift       # Profile prompts
│   │
│   ├── Services/                     # Business logic layer
│   │   ├── AuthService.swift         # Authentication
│   │   ├── UserService.swift         # User management
│   │   ├── MatchService.swift        # Connection operations
│   │   ├── MessageService.swift      # Messaging
│   │   ├── SwipeService.swift        # Like/pass logic
│   │   └── ...
│   │
│   ├── Views/                        # SwiftUI views
│   └── Utilities/                    # Helper classes
│
├── CelestiaTests/                    # Unit tests
├── Admin/                            # Admin web dashboard
├── CloudFunctions/                   # Firebase cloud functions
└── Documentation/                    # Guides and docs
```

## Security

### Reporting Security Issues

Please email security concerns to: support@cofoundry.app

**Do not** open public issues for security vulnerabilities.

### Security Best Practices

- Never commit `GoogleService-Info.plist` with real credentials
- Use environment variables for sensitive data
- Implement proper Firestore security rules
- Validate all user input server-side
- Use HTTPS for all network requests
- Implement rate limiting for API calls

## Roadmap

### Planned Features

- [ ] Voice messages in chat
- [ ] Video calling with connections
- [ ] Founder stories feature
- [ ] Group chats for teams
- [ ] Advanced AI matching algorithm
- [ ] Video profile support
- [ ] In-app meeting planning tools

## Support

### Documentation

- [Firebase Setup Guide](./FIREBASE_EMAIL_SETUP.md)
- [Apple StoreKit Documentation](https://developer.apple.com/storekit/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

### Contact

- **Email**: support@cofoundry.app
- **Website**: https://cofoundry.app

## License

Copyright © 2025 CoFoundry. All rights reserved.

## Acknowledgments

- Firebase for backend infrastructure
- Apple for StoreKit and SwiftUI
- All contributors and beta testers

---

**Built with ❤️ using SwiftUI and Firebase**

*Find your co-founder, build your vision*

*Last Updated: December 2025*
