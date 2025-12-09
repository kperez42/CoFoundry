//
//  MeetingCheckInManager.swift
//  CoFoundry
//
//  Manages meeting check-in and safety features for in-person co-founder meetups
//

import Foundation
import Combine
import CoreLocation

// MARK: - Meeting Check-In Manager

@MainActor
class MeetingCheckInManager: ObservableObject {

    // MARK: - Singleton

    static let shared = MeetingCheckInManager()

    // MARK: - Published Properties

    @Published var activeCheckIns: [MeetingCheckIn] = []
    @Published var scheduledCheckIns: [MeetingCheckIn] = []
    @Published var pastCheckIns: [MeetingCheckIn] = []
    @Published var hasActiveCheckIn: Bool = false

    // MARK: - Properties

    private var checkInTimers: [String: Timer] = [:]
    private let defaults = UserDefaults.standard

    // MARK: - Initialization

    private init() {
        loadCheckIns()
        Logger.shared.info("MeetingCheckInManager initialized", category: .general)
    }

    // MARK: - Check-In Management

    /// Schedule a meeting check-in
    func scheduleCheckIn(
        matchId: String,
        matchName: String,
        location: String,
        scheduledTime: Date,
        checkInTime: Date,
        trustedContacts: [EmergencyContact]
    ) async throws -> MeetingCheckIn {

        Logger.shared.info("Scheduling check-in for meeting with: \(matchName)", category: .general)

        // Validate times
        guard scheduledTime > Date() else {
            throw CoFoundryError.invalidData
        }

        guard checkInTime > scheduledTime else {
            throw CoFoundryError.invalidData
        }

        // Create check-in
        let checkIn = MeetingCheckIn(
            id: UUID().uuidString,
            matchId: matchId,
            matchName: matchName,
            location: location,
            scheduledTime: scheduledTime,
            checkInTime: checkInTime,
            trustedContacts: trustedContacts,
            status: .scheduled
        )

        // Add to scheduled list
        scheduledCheckIns.append(checkIn)
        saveCheckIns()

        // Schedule notifications
        try await scheduleCheckInNotifications(for: checkIn)

        // Track analytics
        AnalyticsManager.shared.logEvent(.meetingCheckInScheduled, parameters: [
            "match_id": matchId,
            "scheduled_time": scheduledTime.timeIntervalSince1970
        ])

        Logger.shared.info("Check-in scheduled successfully", category: .general)

        return checkIn
    }

    /// Start an active check-in
    func startCheckIn(checkInId: String) async throws {
        guard let index = scheduledCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw CoFoundryError.checkInNotFound
        }

        var checkIn = scheduledCheckIns.remove(at: index)
        checkIn.status = .active
        checkIn.activatedAt = Date()

        activeCheckIns.append(checkIn)
        hasActiveCheckIn = true
        saveCheckIns()

        // Start monitoring
        startMonitoring(checkIn: checkIn)

        // Notify trusted contacts
        await notifyTrustedContacts(checkIn: checkIn, message: "Check-in started for meeting with \(checkIn.matchName)")

        // Track analytics
        AnalyticsManager.shared.logEvent(.meetingCheckInStarted, parameters: [
            "check_in_id": checkInId
        ])

        Logger.shared.info("Check-in started: \(checkInId)", category: .general)
    }

    /// Complete a check-in (user is safe)
    func completeCheckIn(checkInId: String) async throws {
        guard let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw CoFoundryError.checkInNotFound
        }

        var checkIn = activeCheckIns.remove(at: index)
        checkIn.status = .completed
        checkIn.completedAt = Date()

        pastCheckIns.insert(checkIn, at: 0)
        hasActiveCheckIn = activeCheckIns.isEmpty == false
        saveCheckIns()

        // Stop monitoring
        stopMonitoring(checkInId: checkInId)

        // Notify trusted contacts
        await notifyTrustedContacts(checkIn: checkIn, message: "Check-in completed successfully")

        // Track analytics
        AnalyticsManager.shared.logEvent(.meetingCheckInCompleted, parameters: [
            "check_in_id": checkInId,
            "duration": checkIn.completedAt?.timeIntervalSince(checkIn.activatedAt ?? Date()) ?? 0
        ])

        Logger.shared.info("Check-in completed: \(checkInId)", category: .general)
    }

    /// Cancel a check-in
    func cancelCheckIn(checkInId: String) async throws {
        // Check scheduled list
        if let index = scheduledCheckIns.firstIndex(where: { $0.id == checkInId }) {
            var checkIn = scheduledCheckIns.remove(at: index)
            checkIn.status = .cancelled

            pastCheckIns.insert(checkIn, at: 0)
            saveCheckIns()

            Logger.shared.info("Scheduled check-in cancelled: \(checkInId)", category: .general)
            return
        }

        // Check active list
        if let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) {
            var checkIn = activeCheckIns.remove(at: index)
            checkIn.status = .cancelled

            pastCheckIns.insert(checkIn, at: 0)
            hasActiveCheckIn = activeCheckIns.isEmpty == false
            saveCheckIns()

            stopMonitoring(checkInId: checkInId)

            Logger.shared.info("Active check-in cancelled: \(checkInId)", category: .general)
            return
        }

        throw CoFoundryError.checkInNotFound
    }

    /// Trigger emergency alert
    func triggerEmergency(checkInId: String) async throws {
        guard let index = activeCheckIns.firstIndex(where: { $0.id == checkInId }) else {
            throw CoFoundryError.checkInNotFound
        }

        var checkIn = activeCheckIns[index]
        checkIn.status = .emergency
        activeCheckIns[index] = checkIn
        saveCheckIns()

        // Send emergency notifications
        await sendEmergencyAlerts(checkIn: checkIn)

        // Track analytics
        AnalyticsManager.shared.logEvent(.emergencyTriggered, parameters: [
            "check_in_id": checkInId
        ])

        Logger.shared.warning("Emergency triggered for check-in: \(checkInId)", category: .general)
    }

    // MARK: - Monitoring

    private func startMonitoring(checkIn: MeetingCheckIn) {
        // Set up timer to check if user checks in on time
        let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.checkCheckInStatus(checkIn: checkIn)
            }
        }

        checkInTimers[checkIn.id] = timer
    }

    private func stopMonitoring(checkInId: String) {
        checkInTimers[checkInId]?.invalidate()
        checkInTimers.removeValue(forKey: checkInId)
    }

    private func checkCheckInStatus(checkIn: MeetingCheckIn) async {
        // Check if check-in time has passed
        guard Date() > checkIn.checkInTime else { return }

        // If user hasn't checked in, trigger alert
        if checkIn.status == .active {
            Logger.shared.warning("Check-in overdue: \(checkIn.id)", category: .general)

            // Send warning notification
            await notifyTrustedContacts(
                checkIn: checkIn,
                message: "⚠️ Check-in overdue for meeting with \(checkIn.matchName)"
            )

            // Trigger emergency after grace period
            let gracePeriod: TimeInterval = 15 * 60 // 15 minutes
            if Date().timeIntervalSince(checkIn.checkInTime) > gracePeriod {
                try? await triggerEmergency(checkInId: checkIn.id)
            }
        }
    }

    // MARK: - Notifications

    private func scheduleCheckInNotifications(for checkIn: MeetingCheckIn) async throws {
        // Schedule reminder before meeting
        // Schedule check-in reminder
        // In production, use UNUserNotificationCenter
        Logger.shared.debug("Scheduled notifications for check-in: \(checkIn.id)", category: .general)
    }

    private func notifyTrustedContacts(checkIn: MeetingCheckIn, message: String) async {
        for contact in checkIn.trustedContacts {
            // In production, send SMS or call trusted contacts
            Logger.shared.info("Notifying trusted contact: \(contact.name)", category: .general)
        }
    }

    private func sendEmergencyAlerts(checkIn: MeetingCheckIn) async {
        // Send emergency SMS/calls to all contacts
        // Include location, match info, and emergency details
        for contact in checkIn.trustedContacts {
            Logger.shared.warning("EMERGENCY: Notifying \(contact.name) about meeting with \(checkIn.matchName)", category: .general)
        }

        // In production, also:
        // - Call emergency services if no response
        // - Send location updates
        // - Trigger loud alarm on device
    }

    // MARK: - Persistence

    private func loadCheckIns() {
        // Load from UserDefaults or database
        // In production, use Firestore or Core Data
    }

    private func saveCheckIns() {
        // Save to UserDefaults or database
    }

    // MARK: - Cleanup

    func cleanup() {
        // Cancel all timers
        for timer in checkInTimers.values {
            timer.invalidate()
        }
        checkInTimers.removeAll()
    }
}

// MARK: - Meeting Check-In Model

struct MeetingCheckIn: Identifiable, Codable {
    let id: String
    let matchId: String
    let matchName: String
    let location: String
    let scheduledTime: Date
    let checkInTime: Date
    let trustedContacts: [EmergencyContact]
    var status: CheckInStatus
    var activatedAt: Date?
    var completedAt: Date?

    enum CheckInStatus: String, Codable {
        case scheduled
        case active
        case completed
        case cancelled
        case emergency
    }
}

// MARK: - Legacy Alias for backward compatibility

typealias DateCheckInManager = MeetingCheckInManager
typealias DateCheckIn = MeetingCheckIn
