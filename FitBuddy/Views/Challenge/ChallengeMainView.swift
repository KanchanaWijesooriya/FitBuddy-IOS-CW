//
//  ChallengeMainView.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-09-04.
//

import SwiftUI

struct ChallengeMainView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedTab = 0 // 0: Competitive, 1: Daily
    @State private var searchText = ""
    @State private var showingCreateChallenge = false
    @State private var competitiveChallenges: [CompetitiveChallenge] = []
    @State private var dailyChallenges: [DailyChallenge] = []
    @State private var activeChallenges: [CompetitiveChallenge] = []
    
    // App's consistent theme colors
    private let primaryAccent = Color.blue
    private let challengeOrange = Color.orange
    private let challengePurple = Color.purple
    private let cardBackground = Color(.systemBackground)
    
    // Haptic feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with common theme
            headerSection
            
            // Tab Selector
            tabSelectorSection
            
            // Main Content
            ScrollView {
                VStack(spacing: 24) {
                    if selectedTab == 0 {
                        competitiveChallengesContent
                    } else {
                        dailyChallengesContent
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .refreshable {
                await refreshChallenges()
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            loadChallenges()
        }
        .sheet(isPresented: $showingCreateChallenge) {
            CreateChallengeView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton()
                Spacer()
                
                // Create Challenge Button
                Button(action: {
                    lightFeedback.impactOccurred()
                    showingCreateChallenge = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(primaryAccent)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Challenges")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Compete with friends or challenge yourself")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(challengeOrange.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "trophy.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(challengeOrange)
                        .shadow(color: challengeOrange.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(.body, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Search challenges...", text: $searchText)
                    .font(.system(.body, design: .rounded))
                    .submitLabel(.search)
                
                if !searchText.isEmpty {
                    Button(action: {
                        lightFeedback.impactOccurred()
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(.body, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Tab Selector Section
    private var tabSelectorSection: some View {
        HStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { index in
                let title = index == 0 ? "Competitive" : "Daily Goals"
                let icon = index == 0 ? "person.2.fill" : "target"
                let isSelected = selectedTab == index
                
                Button(action: {
                    lightFeedback.impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(.callout, weight: .medium))
                            .foregroundColor(isSelected ? .white : .secondary)
                        
                        Text(title)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(isSelected ? .semibold : .medium)
                            .foregroundColor(isSelected ? .white : .secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? primaryAccent : Color.clear)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.8))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Competitive Challenges Content
    private var competitiveChallengesContent: some View {
        VStack(spacing: 24) {
            // Active Challenges Section
            if !activeChallenges.isEmpty {
                activeCompetitiveChallengesSection
            }
            
            // Available Challenges Section
            availableCompetitiveChallengesSection
            
            // Friends Section
            friendsChallengeSection
        }
        .padding(.horizontal, 20)
    }
    
    private var activeCompetitiveChallengesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(challengeOrange)
                
                Text("Active Challenges")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(activeChallenges.count)")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(challengeOrange)
                    .cornerRadius(8)
            }
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(activeChallenges) { challenge in
                    ActiveChallengeCard(challenge: challenge)
                }
            }
        }
    }
    
    private var availableCompetitiveChallengesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(primaryAccent)
                
                Text("Join Challenges")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    lightFeedback.impactOccurred()
                    // Refresh challenges
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(.callout, weight: .medium))
                        .foregroundColor(primaryAccent)
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(filteredCompetitiveChallenges) { challenge in
                    Button(action: {
                        navigationCoordinator.navigateToChallengeDetail(
                            challengeId: challenge.id.uuidString,
                            challengeData: [
                                "title": challenge.title,
                                "type": challenge.type.rawValue,
                                "participants": challenge.participants.count,
                                "description": challenge.description
                            ]
                        )
                    }) {
                        CompetitiveChallengeCard(challenge: challenge) {
                            impactFeedback.impactOccurred()
                            joinChallenge(challenge)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var friendsChallengeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(challengePurple)
                
                Text("Challenge Friends")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Quick friend challenge buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sampleFriends, id: \.id) { friend in
                        FriendChallengeCard(friend: friend) {
                            impactFeedback.impactOccurred()
                            challengeFriend(friend)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Daily Challenges Content
    private var dailyChallengesContent: some View {
        VStack(spacing: 24) {
            // Today's Progress
            todaysProgressSection
            
            // Available Daily Challenges
            availableDailyChallengesSection
        }
        .padding(.horizontal, 20)
    }
    
    private var todaysProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(primaryAccent)
                
                Text("Today's Progress")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(completedDailyToday)/\(dailyChallenges.count)")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(primaryAccent)
                    .cornerRadius(8)
            }
            
            // Progress Ring
            ProgressRingView(
                progress: Double(completedDailyToday) / Double(max(dailyChallenges.count, 1)),
                primaryColor: primaryAccent,
                secondaryColor: Color(.systemGray5)
            )
        }
    }
    
    private var availableDailyChallengesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(primaryAccent)
                
                Text("Daily Challenges")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(filteredDailyChallenges) { challenge in
                    DailyChallengeCard(challenge: challenge) {
                        impactFeedback.impactOccurred()
                        completeDailyChallenge(challenge)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredCompetitiveChallenges: [CompetitiveChallenge] {
        if searchText.isEmpty {
            return competitiveChallenges
        }
        return competitiveChallenges.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    private var filteredDailyChallenges: [DailyChallenge] {
        if searchText.isEmpty {
            return dailyChallenges
        }
        return dailyChallenges.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    private var completedDailyToday: Int {
        dailyChallenges.filter { $0.isCompleted }.count
    }
    
    // MARK: - Data Loading
    private func loadChallenges() {
        // Sample competitive challenges
        competitiveChallenges = [
            CompetitiveChallenge(
                id: UUID(),
                title: "10K Steps Battle",
                description: "First to reach 10,000 steps wins!",
                type: .steps,
                goal: 10000,
                participants: ["John Doe", "Sarah Kim", "Mike Chen"],
                timeRemaining: "2d 5h",
                difficulty: .medium,
                reward: "🏆 Champion Badge",
                isActive: false,
                progress: 0.0
            ),
            CompetitiveChallenge(
                id: UUID(),
                title: "Core Crusher",
                description: "100 abs exercises in 3 days",
                type: .workout,
                goal: 100,
                participants: ["Emma Wilson", "Alex Park"],
                timeRemaining: "1d 12h",
                difficulty: .hard,
                reward: "💪 Abs Master",
                isActive: false,
                progress: 0.0
            ),
            CompetitiveChallenge(
                id: UUID(),
                title: "Hydration Hero",
                description: "Drink 3L water daily for a week",
                type: .water,
                goal: 3000,
                participants: ["Lisa Johnson", "Tom Brown", "Amy Lee", "Chris Davis"],
                timeRemaining: "5d 8h",
                difficulty: .easy,
                reward: "💧 Hydration Expert",
                isActive: false,
                progress: 0.0
            )
        ]
        
        // Sample active challenges
        activeChallenges = [
            CompetitiveChallenge(
                id: UUID(),
                title: "Weekend Warrior",
                description: "5000 steps before noon",
                type: .steps,
                goal: 5000,
                participants: ["You", "Jake Miller"],
                timeRemaining: "3h 45m",
                difficulty: .medium,
                reward: "⚡ Early Bird",
                isActive: true,
                progress: 0.75
            )
        ]
        
        // Sample daily challenges
        dailyChallenges = [
            DailyChallenge(
                id: UUID(),
                title: "Morning Stretch",
                description: "Complete 5-minute stretching routine",
                type: .flexibility,
                duration: "5 min",
                calories: 25,
                difficulty: .easy,
                isCompleted: false,
                icon: "figure.flexibility"
            ),
            DailyChallenge(
                id: UUID(),
                title: "Stair Climb",
                description: "Climb 5 flights of stairs",
                type: .cardio,
                duration: "10 min",
                calories: 80,
                difficulty: .medium,
                isCompleted: true,
                icon: "figure.stairs"
            ),
            DailyChallenge(
                id: UUID(),
                title: "Plank Power",
                description: "Hold plank for 60 seconds",
                type: .strength,
                duration: "1 min",
                calories: 15,
                difficulty: .medium,
                isCompleted: false,
                icon: "figure.core.training"
            ),
            DailyChallenge(
                id: UUID(),
                title: "Hydration Check",
                description: "Drink 8 glasses of water",
                type: .wellness,
                duration: "All day",
                calories: 0,
                difficulty: .easy,
                isCompleted: false,
                icon: "drop.fill"
            )
        ]
    }
    
    private func refreshChallenges() async {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loadChallenges()
    }
    
    private func joinChallenge(_ challenge: CompetitiveChallenge) {
        // TODO: Implement join challenge logic
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let index = competitiveChallenges.firstIndex(where: { $0.id == challenge.id }) {
                var updatedChallenge = challenge
                updatedChallenge.isActive = true
                activeChallenges.append(updatedChallenge)
                competitiveChallenges.remove(at: index)
            }
        }
    }
    
    private func completeDailyChallenge(_ challenge: DailyChallenge) {
        // TODO: Implement complete daily challenge logic
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let index = dailyChallenges.firstIndex(where: { $0.id == challenge.id }) {
                dailyChallenges[index].isCompleted.toggle()
            }
        }
    }
    
    private func challengeFriend(_ friend: Friend) {
        // TODO: Implement challenge friend logic
        showingCreateChallenge = true
    }
}

// MARK: - Supporting Views

struct ActiveChallengeCard: View {
    let challenge: CompetitiveChallenge
    private let primaryAccent = Color.blue
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(challenge.description)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("⏰")
                        .font(.system(.callout))
                    
                    Text(challenge.timeRemaining)
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            
            // Progress Section
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(challenge.progress * 100))%")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(primaryAccent)
                }
                
                ProgressView(value: challenge.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryAccent))
                    .scaleEffect(y: 2.0)
            }
            
            // Participants
            HStack {
                Text("vs \(challenge.participants.dropFirst().joined(separator: ", "))")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(challenge.reward)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(primaryAccent)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(primaryAccent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CompetitiveChallengeCard: View {
    let challenge: CompetitiveChallenge
    let onJoin: () -> Void
    private let primaryAccent = Color.blue
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(challenge.title)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        DifficultyBadge(difficulty: challenge.difficulty)
                    }
                    
                    Text(challenge.description)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                TypeIcon(type: challenge.type)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(.caption2, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(challenge.participants.count) participants")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(.caption2, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Text(challenge.timeRemaining)
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Button(action: onJoin) {
                    Text("Join")
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(primaryAccent)
                        .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

struct DailyChallengeCard: View {
    let challenge: DailyChallenge
    let onComplete: () -> Void
    private let primaryAccent = Color.blue
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Section
            ZStack {
                Circle()
                    .fill(challenge.isCompleted ? primaryAccent.opacity(0.2) : typeColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(primaryAccent)
                } else {
                    Image(systemName: challenge.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(typeColor)
                }
            }
            
            // Content Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(challenge.title)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .strikethrough(challenge.isCompleted)
                    
                    Spacer()
                    
                    DifficultyBadge(difficulty: challenge.difficulty)
                }
                
                Text(challenge.description)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(.caption2, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(challenge.duration)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(.caption2, weight: .medium))
                            .foregroundColor(.orange)
                        Text("\(challenge.calories) cal")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    if !challenge.isCompleted {
                        Button(action: onComplete) {
                            Text("Complete")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(primaryAccent)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(challenge.isCompleted ? primaryAccent.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .opacity(challenge.isCompleted ? 0.7 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: challenge.isCompleted)
    }
    
    private var typeColor: Color {
        switch challenge.type {
        case .cardio: return Color.red
        case .strength: return Color.purple
        case .flexibility: return Color.blue
        case .wellness: return Color.green
        }
    }
}

struct FriendChallengeCard: View {
    let friend: Friend
    let onChallenge: () -> Void
    private let primaryAccent = Color.blue
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(friend.isOnline ? primaryAccent.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                
                Text(String(friend.name.prefix(1)))
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(friend.isOnline ? primaryAccent : .secondary)
                
                if friend.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .offset(x: 20, y: -20)
                }
            }
            
            VStack(spacing: 4) {
                Text(friend.name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(friend.status)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Button(action: onChallenge) {
                Text("Challenge")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(primaryAccent)
                    .cornerRadius(8)
            }
        }
        .frame(width: 100)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Helper Views

struct ProgressRingView: View {
    let progress: Double
    let primaryColor: Color
    let secondaryColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(secondaryColor, lineWidth: 12)
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(primaryColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Complete")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: ChallengeDifficulty
    
    var body: some View {
        Text(difficulty.rawValue.capitalized)
            .font(.system(.caption2, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(difficultyColor)
            .cornerRadius(6)
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return Color.green
        case .medium: return Color.orange
        case .hard: return Color.red
        }
    }
}

struct TypeIcon: View {
    let type: ChallengeType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(typeColor.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Image(systemName: typeIcon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(typeColor)
        }
    }
    
    private var typeColor: Color {
        switch type {
        case .steps: return Color.blue
        case .workout: return Color.purple
        case .water: return Color.cyan
        }
    }
    
    private var typeIcon: String {
        switch type {
        case .steps: return "figure.walk"
        case .workout: return "dumbbell.fill"
        case .water: return "drop.fill"
        }
    }
}

// MARK: - Data Models

struct CompetitiveChallenge: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let type: ChallengeType
    let goal: Int
    let participants: [String]
    let timeRemaining: String
    let difficulty: ChallengeDifficulty
    let reward: String
    var isActive: Bool
    var progress: Double
}

struct DailyChallenge: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let type: DailyChallengeType
    let duration: String
    let calories: Int
    let difficulty: ChallengeDifficulty
    var isCompleted: Bool
    let icon: String
}

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let status: String
    let isOnline: Bool
}

enum ChallengeType: String, CaseIterable {
    case steps = "steps"
    case workout = "workout" 
    case water = "water"
}

enum DailyChallengeType {
    case cardio, strength, flexibility, wellness
}

enum ChallengeDifficulty: String {
    case easy, medium, hard
}

// Sample friends data
let sampleFriends = [
    Friend(name: "Sarah Kim", status: "5.2K steps", isOnline: true),
    Friend(name: "Mike Chen", status: "3 workouts", isOnline: false),
    Friend(name: "Emma Wilson", status: "2.1L water", isOnline: true),
    Friend(name: "Alex Park", status: "8K steps", isOnline: false)
]

// Placeholder for Create Challenge View
struct CreateChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create Challenge")
                    .font(.title)
                    .padding()
                
                Text("Coming soon...")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChallengeMainView()
    }
}
