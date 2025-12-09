//
//  SearchFilterView.swift
//  CoFoundry
//
//  Comprehensive search filter interface for co-founder matching
//

import SwiftUI

struct SearchFilterView: View {

    @StateObject private var searchManager = SearchManager.shared
    @StateObject private var presetManager = FilterPresetManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var filter: SearchFilter
    @State private var showingPresetSheet = false
    @State private var showingSavePresetSheet = false

    init(filter: SearchFilter = SearchFilter()) {
        _filter = State(initialValue: filter)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Active filter count
                    if filter.activeFilterCount > 0 {
                        activeFiltersCard
                    }

                    // Location & Distance
                    locationSection

                    // Professional Background
                    professionalSection

                    // Co-Founder Goals
                    cofounderGoalsSection

                    // Skills & Industries
                    skillsSection

                    // Startup Stage & Commitment
                    startupSection

                    // Funding & Equity
                    fundingSection

                    // Preferences
                    preferencesSection
                }
                .padding()
            }
            .navigationTitle("Filter Founders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filter.reset()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingSavePresetSheet = true }) {
                            Label("Save as Preset", systemImage: "bookmark")
                        }

                        Button(action: { showingPresetSheet = true }) {
                            Label("Load Preset", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                searchButton
            }
        }
        .sheet(isPresented: $showingPresetSheet) {
            FilterPresetsView(onSelect: { preset in
                filter = preset.filter
                showingPresetSheet = false
            })
        }
        .sheet(isPresented: $showingSavePresetSheet) {
            SavePresetSheet(filter: filter)
        }
    }

    // MARK: - Active Filters Card

    private var activeFiltersCard: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(.blue)

            Text("\(filter.activeFilterCount) active filters")
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Button("Clear All") {
                filter.reset()
            }
            .font(.subheadline)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Location Section

    private var locationSection: some View {
        FilterSection(title: "Location", icon: "location.fill") {
            VStack(spacing: 16) {
                // Location Preference
                Picker("Work Preference", selection: $filter.locationPreference) {
                    ForEach(LocationPreference.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)

                // Distance slider (for local preference)
                if filter.locationPreference == .local || filter.locationPreference == .hybrid {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Max Distance")
                                .font(.subheadline)
                            Spacer()
                            Text("\(filter.distanceRadius) miles")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }

                        Slider(value: Binding(
                            get: { Double(filter.distanceRadius) },
                            set: { filter.distanceRadius = Int($0) }
                        ), in: 1...100, step: 1)
                    }
                }

                // Use current location toggle
                Toggle("Use my current location", isOn: $filter.useCurrentLocation)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Professional Section

    private var professionalSection: some View {
        FilterSection(title: "Professional Background", icon: "person.fill") {
            VStack(spacing: 16) {
                // Years of experience
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Years of Experience")
                            .font(.subheadline)
                        Spacer()
                        if let min = filter.yearsExperienceMin, let max = filter.yearsExperienceMax {
                            Text("\(min) - \(max) years")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }

                    HStack {
                        Picker("Min", selection: Binding(
                            get: { filter.yearsExperienceMin ?? 0 },
                            set: { filter.yearsExperienceMin = $0 > 0 ? $0 : nil }
                        )) {
                            Text("Any").tag(0)
                            ForEach([1, 2, 3, 5, 7, 10, 15, 20], id: \.self) { years in
                                Text("\(years)+").tag(years)
                            }
                        }
                        .pickerStyle(.menu)

                        Text("to")
                            .font(.caption)

                        Picker("Max", selection: Binding(
                            get: { filter.yearsExperienceMax ?? 50 },
                            set: { filter.yearsExperienceMax = $0 < 50 ? $0 : nil }
                        )) {
                            ForEach([5, 10, 15, 20, 30, 40], id: \.self) { years in
                                Text("\(years)").tag(years)
                            }
                            Text("Any").tag(50)
                        }
                        .pickerStyle(.menu)
                    }
                }

                Divider()

                // Previous startups
                Picker("Previous Startups", selection: Binding(
                    get: { filter.previousStartupsMin ?? 0 },
                    set: { filter.previousStartupsMin = $0 > 0 ? $0 : nil }
                )) {
                    Text("Any").tag(0)
                    Text("1+ startup").tag(1)
                    Text("2+ startups").tag(2)
                    Text("3+ startups").tag(3)
                    Text("5+ startups").tag(5)
                }
                .pickerStyle(.menu)

                Divider()

                // Education
                MultiSelectMenu(
                    title: "Education",
                    options: EducationLevel.allCases,
                    selections: $filter.educationLevels,
                    displayName: { $0.displayName }
                )
            }
        }
    }

    // MARK: - Co-Founder Goals Section

    private var cofounderGoalsSection: some View {
        FilterSection(title: "Co-Founder Goals", icon: "person.2.fill") {
            VStack(spacing: 16) {
                MultiSelectMenu(
                    title: "Looking for",
                    options: StartupGoal.allCases,
                    selections: $filter.startupGoals,
                    displayName: { $0.displayName }
                )
            }
        }
    }

    // MARK: - Skills Section

    private var skillsSection: some View {
        FilterSection(title: "Skills & Industries", icon: "star.fill") {
            VStack(spacing: 16) {
                // Skills they're offering
                MultiSelectMenu(
                    title: "Skills Offered",
                    options: SkillSet.allCases,
                    selections: $filter.skillsOffered,
                    displayName: { $0.displayName }
                )

                Divider()

                // Skills they're seeking
                MultiSelectMenu(
                    title: "Skills Seeking",
                    options: SkillSet.allCases,
                    selections: $filter.skillsSeeking,
                    displayName: { $0.displayName }
                )

                Divider()

                // Industries
                MultiSelectMenu(
                    title: "Industries",
                    options: Industry.allCases,
                    selections: $filter.industries,
                    displayName: { $0.displayName }
                )
            }
        }
    }

    // MARK: - Startup Section

    private var startupSection: some View {
        FilterSection(title: "Startup Stage & Commitment", icon: "rocket.fill") {
            VStack(spacing: 16) {
                // Startup stage
                MultiSelectMenu(
                    title: "Startup Stage",
                    options: StartupStage.allCases,
                    selections: $filter.startupStages,
                    displayName: { $0.displayName }
                )

                Divider()

                // Commitment level
                MultiSelectMenu(
                    title: "Time Commitment",
                    options: Commitment.allCases,
                    selections: $filter.commitmentLevels,
                    displayName: { $0.displayName }
                )
            }
        }
    }

    // MARK: - Funding Section

    private var fundingSection: some View {
        FilterSection(title: "Funding & Equity", icon: "dollarsign.circle.fill") {
            VStack(spacing: 16) {
                // Funding experience
                MultiSelectMenu(
                    title: "Funding Experience",
                    options: FundingExperience.allCases,
                    selections: $filter.fundingExperience,
                    displayName: { $0.displayName }
                )

                Divider()

                // Currently funded
                Picker("Currently Funded", selection: $filter.currentlyFunded) {
                    ForEach(LifestyleFilter.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)

                Divider()

                // Equity expectations
                MultiSelectMenu(
                    title: "Equity Expectations",
                    options: EquityExpectation.allCases,
                    selections: $filter.equityExpectations,
                    displayName: { $0.displayName }
                )
            }
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        FilterSection(title: "Preferences", icon: "slider.horizontal.3") {
            VStack(spacing: 16) {
                Toggle("Verified profiles only", isOn: $filter.verifiedOnly)
                    .font(.subheadline)

                Toggle("With photos only", isOn: $filter.withPhotosOnly)
                    .font(.subheadline)

                Divider()

                // Active recently
                Picker("Active in last", selection: Binding(
                    get: { filter.activeInLastDays ?? 0 },
                    set: { filter.activeInLastDays = $0 > 0 ? $0 : nil }
                )) {
                    Text("Any time").tag(0)
                    Text("24 hours").tag(1)
                    Text("7 days").tag(7)
                    Text("30 days").tag(30)
                }
                .pickerStyle(.menu)

                Toggle("New users only (last 30 days)", isOn: $filter.newUsers)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Search Button

    private var searchButton: some View {
        Button(action: {
            Task {
                await searchManager.search(with: filter)
                presetManager.addToHistory(filter: filter, resultsCount: searchManager.totalResultsCount)
                dismiss()
            }
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Find Co-Founders")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Filter Section Component

struct FilterSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }

            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Multi-Select Menu

struct MultiSelectMenu<T: Hashable>: View {
    let title: String
    let options: [T]
    @Binding var selections: [T]
    let displayName: (T) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)

                Spacer()

                if !selections.isEmpty {
                    Text("\(selections.count) selected")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Selected items
            if !selections.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(selections.enumerated()), id: \.0) { _, item in
                            HStack(spacing: 4) {
                                Text(displayName(item))
                                    .font(.caption)

                                Button(action: {
                                    selections.removeAll { $0 == item }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
            }

            // Selection menu
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if selections.contains(option) {
                            selections.removeAll { $0 == option }
                        } else {
                            selections.append(option)
                        }
                    }) {
                        HStack {
                            Text(displayName(option))
                            if selections.contains(option) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text("Select...")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Save Preset Sheet

struct SavePresetSheet: View {
    @StateObject private var presetManager = FilterPresetManager.shared
    @Environment(\.dismiss) private var dismiss

    let filter: SearchFilter
    @State private var presetName = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Preset Name") {
                    TextField("e.g., Technical Co-founders", text: $presetName)
                }

                Section("Filter Summary") {
                    Text("\(filter.activeFilterCount) active filters")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Save Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        do {
                            _ = try presetManager.savePreset(name: presetName, filter: filter)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showingError = true
                        }
                    }
                    .disabled(presetName.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Preview

struct SearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFilterView()
    }
}
