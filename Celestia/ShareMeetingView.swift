//
//  ShareMeetingView.swift
//  CoFoundry
//
//  Share meeting details with trusted contacts for professional safety
//

import SwiftUI
import FirebaseFirestore
import MapKit

struct ShareMeetingView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ShareMeetingViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedMatch: User?
    @State private var meetingTime = Date()
    @State private var location = ""
    @State private var additionalNotes = ""
    @State private var selectedContacts: Set<EmergencyContact> = []
    @State private var showMatchPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Meeting Details
                meetingDetailsSection

                // Trusted Contacts
                contactsSection

                // Share Button
                shareButton
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Share Meeting Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadTrustedContacts()
        }
        .sheet(item: $viewModel.shareConfirmation) { confirmation in
            MeetingSharedConfirmationView(confirmation: confirmation)
        }
        .sheet(isPresented: $showMatchPicker) {
            MatchPickerView(selectedMatch: $selectedMatch)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.badge.gearshape")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text("Stay Safe During Meetings")
                .font(.title2.bold())

            Text("Share your meeting plans with trusted contacts. They'll receive your details and can check in on you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Meeting Details Section

    private var meetingDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meeting Details")
                .font(.headline)

            VStack(spacing: 16) {
                // Match Selection
                Button {
                    showMatchPicker = true
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.purple)

                        VStack(alignment: .leading) {
                            Text("Who are you meeting?")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(selectedMatch?.fullName ?? "Select co-founder")
                                .font(.body)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }

                // Meeting Date & Time
                VStack(alignment: .leading, spacing: 8) {
                    Label("Date & Time", systemImage: "calendar.clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    DatePicker("", selection: $meetingTime, in: Date()...)
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }

                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Label("Location", systemImage: "mappin.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Coffee shop, coworking space, or address", text: $location)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }

                // Additional Notes
                VStack(alignment: .leading, spacing: 8) {
                    Label("Additional Notes (Optional)", systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $additionalNotes)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - Contacts Section

    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Share With")
                    .font(.headline)

                Spacer()

                NavigationLink {
                    TrustedContactsView()
                } label: {
                    Text("Manage")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            if viewModel.trustedContacts.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No Trusted Contacts")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Add trusted contacts who can check on you during your meetings.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    NavigationLink {
                        TrustedContactsView()
                    } label: {
                        Text("Add Contacts")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
            } else {
                // Contacts list
                VStack(spacing: 8) {
                    ForEach(viewModel.trustedContacts) { contact in
                        ContactSelectionRow(
                            contact: contact,
                            isSelected: selectedContacts.contains(contact)
                        ) {
                            if selectedContacts.contains(contact) {
                                selectedContacts.remove(contact)
                            } else {
                                selectedContacts.insert(contact)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            Task {
                await viewModel.shareMeetingDetails(
                    match: selectedMatch,
                    meetingTime: meetingTime,
                    location: location,
                    notes: additionalNotes,
                    contacts: Array(selectedContacts)
                )
            }
        } label: {
            HStack {
                Image(systemName: "paperplane.fill")
                Text("Share Meeting Details")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
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
        .disabled(!viewModel.canShare(
            match: selectedMatch,
            location: location,
            contacts: selectedContacts
        ))
        .opacity(viewModel.canShare(
            match: selectedMatch,
            location: location,
            contacts: selectedContacts
        ) ? 1.0 : 0.5)
    }
}

// MARK: - Meeting Shared Confirmation View

struct MeetingSharedConfirmationView: View {
    let confirmation: MeetingShareConfirmation
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }

                // Message
                VStack(spacing: 12) {
                    Text("Meeting Details Shared!")
                        .font(.title.bold())

                    Text("Your trusted contacts have been notified and will receive updates.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Shared with
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shared with:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)

                    ForEach(confirmation.sharedWith, id: \.self) { name in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(name)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)

                Spacer()

                // Done Button
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                }
            }
            .padding()
            .navigationTitle("Success")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Models

struct MeetingShareConfirmation: Identifiable {
    let id = UUID()
    let sharedWith: [String]
    let meetingTime: Date
}

// MARK: - View Model

@MainActor
class ShareMeetingViewModel: ObservableObject {
    @Published var trustedContacts: [EmergencyContact] = []
    @Published var shareConfirmation: MeetingShareConfirmation?

    private let db = Firestore.firestore()

    func loadTrustedContacts() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        do {
            let snapshot = try await db.collection("emergency_contacts")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()

            trustedContacts = snapshot.documents.compactMap { doc in
                let contact = try? doc.data(as: EmergencyContact.self)
                // Filter for contacts that have meeting alerts enabled
                return contact?.notificationPreferences.receiveScheduledDateAlerts == true ? contact : nil
            }

            Logger.shared.info("Loaded \(trustedContacts.count) trusted contacts", category: .general)
        } catch {
            Logger.shared.error("Error loading trusted contacts", category: .general, error: error)
        }
    }

    func canShare(match: User?, location: String, contacts: Set<EmergencyContact>) -> Bool {
        match != nil && !location.isEmpty && !contacts.isEmpty
    }

    func shareMeetingDetails(
        match: User?,
        meetingTime: Date,
        location: String,
        notes: String,
        contacts: [EmergencyContact]
    ) async {
        guard let match = match, let userId = AuthService.shared.currentUser?.id else { return }

        do {
            let meetingShare: [String: Any] = [
                "userId": userId,
                "matchId": match.id as Any,
                "matchName": match.fullName,
                "meetingTime": Timestamp(date: meetingTime),
                "location": location,
                "notes": notes,
                "sharedWith": contacts.map { $0.id },
                "sharedAt": Timestamp(date: Date()),
                "status": "active"
            ]

            try await db.collection("shared_meetings").addDocument(data: meetingShare)

            // Send notifications to contacts
            for contact in contacts {
                try await sendMeetingNotification(to: contact, match: match, meetingTime: meetingTime, location: location)
            }

            shareConfirmation = MeetingShareConfirmation(
                sharedWith: contacts.map { $0.name },
                meetingTime: meetingTime
            )

            AnalyticsServiceEnhanced.shared.trackEvent(
                .featureUsed,
                properties: [
                    "feature": "share_meeting",
                    "contactsCount": contacts.count
                ]
            )

            Logger.shared.info("Meeting details shared with \(contacts.count) contacts", category: .general)
        } catch {
            Logger.shared.error("Error sharing meeting details", category: .general, error: error)
        }
    }

    private func sendMeetingNotification(
        to contact: EmergencyContact,
        match: User,
        meetingTime: Date,
        location: String
    ) async throws {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let notificationData: [String: Any] = [
            "contactId": contact.id,
            "contactName": contact.name,
            "contactEmail": contact.email ?? "",
            "contactPhone": contact.phoneNumber,
            "userId": userId,
            "matchName": match.fullName,
            "meetingTime": Timestamp(date: meetingTime),
            "location": location,
            "formattedDateTime": dateFormatter.string(from: meetingTime),
            "sentAt": Timestamp(date: Date()),
            "type": "safety_meeting_alert"
        ]

        // Save notification to Firestore for tracking
        try await db.collection("safety_notifications").addDocument(data: notificationData)

        let message = """
        Safety Alert from CoFoundry:
        \(AuthService.shared.currentUser?.fullName ?? "A user") has shared their meeting details with you.

        Meeting Time: \(dateFormatter.string(from: meetingTime))
        Meeting With: \(match.fullName)
        Location: \(location)

        This is an automated safety notification for a co-founder meeting.
        """

        Logger.shared.info("""
        Safety notification created for \(contact.name):
        Phone: \(contact.phoneNumber)
        Email: \(contact.email ?? "N/A")
        Message: \(message)
        """, category: .general)
    }
}

// MARK: - Trusted Contacts View (Alias for EmergencyContactsView with better naming)

struct TrustedContactsView: View {
    var body: some View {
        EmergencyContactsView()
    }
}

#Preview {
    NavigationStack {
        ShareMeetingView()
            .environmentObject(AuthService.shared)
    }
}
