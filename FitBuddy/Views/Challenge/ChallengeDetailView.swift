
import SwiftUI

struct ChallengeDetailView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var isJoined = false
    @State private var userProgress: Double = 0.0
    @State private var selectedTab = 0 // 0: Overview, 1: Leaderboard, 2: Activity
    @State private var showingJoinAlert = false
    @State private var participantStats: [ParticipantStat] = []
    @State private var challengeActivity: [ChallengeActivity] = []
    
    // Get challenge data from NavigationCoordinator
    private var challengeTitle: String {
        return navigationCoordinator.challengeData["title"] as? String ?? "Challenge"
    }
    
    private var challengeType: ChallengeType {
        let typeString = navigationCoordinator.challengeData["type"] as? String ?? "workout"
        switch typeString.lowercased() {
        case "steps":
            return .steps
        case "water":
            return .water
        case "workout":
            return .workout
        default:
            return .workout
        }
    }
    
    private var challengeParticipants: Int {
        return navigationCoordinator.challengeData["participants"] as? Int ?? 0
    }
    
    private var challengeDifficulty: ChallengeDifficulty {
        let difficultyString = navigationCoordinator.challengeData["difficulty"] as? String ?? "medium"
        return ChallengeDifficulty(rawValue: difficultyString.lowercased()) ?? .medium
    }
    
    private var challengeDescription: String {
        return navigationCoordinator.challengeData["description"] as? String ?? "Challenge description"
    }
    
    private let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831) // Cyan/Water
    private let primaryPurple = Color(red: 0.588, green: 0.239, blue: 0.729) // Purple
    private let redGradient = Color(red: 0.906, green: 0.298, blue: 0.235) // Red for workout
    private let cardBackground = Color.adaptiveCardBackground
    
    // Haptic feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let successFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            // Tab Selector
            tabSelectorSection
            
            // Main Content
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedTab {
                    case 0:
                        overviewContent
                    case 1:
                        leaderboardContent
                    case 2:
                        activityContent
                    default:
                        overviewContent
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 120) // Increase bottom padding for navigation bar
            }
            .refreshable {
                await refreshData()
            }
        }
        .background(backgroundView)
        .navigationBarHidden(true)
        .onAppear {
            loadChallengeData()
        }
        .alert("Join Challenge", isPresented: $showingJoinAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Join") {
                joinChallenge()
            }
        } message: {
            Text("Are you ready to take on the \"\(challengeTitle)\" challenge?")
        }
        .overlay(
            // Fixed Bottom Action Button
            VStack {
                Spacer()
                
                if !isJoined {
                    joinChallengeButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                } else {
                    progressUpdateButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Navigation
            HStack {
                BackButton()
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Challenge Header Card
            challengeHeaderCard
                .padding(.horizontal, 20)
                .padding(.top, 16)
        }
    }
    
    private var challengeHeaderCard: some View {
        VStack(spacing: 20) {
            // Title and Type
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        TypeIcon(type: challengeType)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challengeTitle)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(challengeDescription)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Challenge Details
                    HStack(spacing: 8) {
                        DetailChip(
                            icon: "person.2.fill",
                            text: "\(challengeParticipants) joined",
                            color: primaryPurple
                        )
                        
                        DetailChip(
                            icon: "clock.fill",
                            text: "7 days left",
                            color: redGradient
                        )
                        
                        DetailChip(
                            icon: "target",
                            text: "10000",
                            color: primaryWater
                        )
                    }
                }
                
                Spacer()
                
                // Difficulty and Reward
                VStack(spacing: 8) {
                    DifficultyBadge(difficulty: challengeDifficulty)
                    
                    Text("50 points")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(primaryWater)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Progress Section (if joined)
            if isJoined {
                userProgressSection
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackground)
                .shadow(color: Color.primary.opacity(0.1), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [primaryWater.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private var userProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Progress")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(userProgress * 10000))/10000")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(primaryWater)
            }
            
            // Progress Bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.adaptiveCardBackground.opacity(0.7))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryWater, primaryWater.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, userProgress * UIScreen.main.bounds.width * 0.7), height: 8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: userProgress)
            }
            
            HStack {
                Text("\(Int(userProgress * 100))% Complete")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Rank: #\(getCurrentUserRank())")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(redGradient)
            }
        }
        .padding(.top, 8)
    }
    
    private var tabSelectorSection: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                let titles = ["Overview", "Leaderboard", "Activity"]
                let icons = ["info.circle", "trophy.fill", "clock.fill"]
                let isSelected = selectedTab == index
                
                Button(action: {
                    lightFeedback.impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: icons[index])
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(isSelected ? .white : .secondary)
                        
                        Text(titles[index])
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(isSelected ? .semibold : .medium)
                            .foregroundColor(isSelected ? .white : .secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? primaryWater : Color.clear)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.adaptiveCardBackground.opacity(0.8))
                .shadow(color: Color.primary.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    
    private var overviewContent: some View {
        VStack(spacing: 24) {
            challengeDescriptionSection
            challengeRulesSection
            participantsPreviewSection
        }
        .padding(.horizontal, 20)
    }
    
    private var challengeDescriptionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(primaryWater)
                
                Text("Challenge Details")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                ChallengeDetailRow(
                    icon: "target",
                    title: "Goal",
                    value: getGoalDescription(),
                    color: primaryWater
                )
                
                ChallengeDetailRow(
                    icon: "calendar",
                    title: "Duration",
                    value: getDurationDescription(),
                    color: redGradient
                )
                
                ChallengeDetailRow(
                    icon: "gift.fill",
                    title: "Reward",
                    value: "50 points",
                    color: primaryPurple
                )
                
                ChallengeDetailRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Difficulty",
                    value: "Medium",
                    color: getDifficultyColor()
                )
            }
        }
    }
    
    private var challengeRulesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(redGradient)
                
                Text("Rules & Guidelines")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(getChallengeRules(), id: \.self) { rule in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(primaryWater)
                            .frame(width: 6, height: 6)
                            .padding(.top, 8)
                        
                        Text(rule)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.adaptiveCardBackground.opacity(0.5))
            )
        }
    }
    
    private var participantsPreviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(primaryPurple)
                
                Text("Participants")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(challengeParticipants)")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(primaryPurple)
                    .cornerRadius(8)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(0..<min(6, challengeParticipants), id: \.self) { index in
                    ParticipantPreviewCard(name: "User \(index + 1)")
                }
                
                if challengeParticipants > 6 {
                    VStack(spacing: 8) {
                        Text("+\(challengeParticipants - 6)")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text("more")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.adaptiveCardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.adaptiveCardBackground.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            )
                    )
                }
            }
        }
    }
    
    private var leaderboardContent: some View {
        VStack(spacing: 24) {
            leaderboardSection
        }
        .padding(.horizontal, 20)
    }
    
    private var leaderboardSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(redGradient)
                
                Text("Leaderboard")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    lightFeedback.impactOccurred()
                    // Refresh leaderboard
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(.callout, weight: .medium))
                        .foregroundColor(primaryWater)
                }
            }
            
            VStack(spacing: 0) {
                ForEach(Array(participantStats.enumerated()), id: \.offset) { index, participant in
                    LeaderboardRow(
                        participant: participant,
                        rank: index + 1,
                        isCurrentUser: participant.name == "You"
                    )
                    
                    if index < participantStats.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBackground)
                    .shadow(color: Color.primary.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private var activityContent: some View {
        VStack(spacing: 24) {
            activitySection
        }
        .padding(.horizontal, 20)
    }
    
    private var activitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(primaryWater)
                
                Text("Recent Activity")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(challengeActivity) { activity in
                    ActivityRow(activity: activity)
                }
                
                if challengeActivity.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No recent activity")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 120)
                }
            }
        }
    }
    
    
    private var joinChallengeButton: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            showingJoinAlert = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text("Join Challenge")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryWater, primaryWater.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: primaryWater.opacity(0.4), radius: 12, x: 0, y: 6)
            )
        }
    }
    
    private var progressUpdateButton: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            updateProgress()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text("Update Progress")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(userProgress * 100))%")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [redGradient, Color.red.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: redGradient.opacity(0.4), radius: 12, x: 0, y: 6)
            )
        }
    }
    
    private var backgroundView: some View {
        Color.adaptiveBackground
            .ignoresSafeArea()
    }
    
    
    private func loadChallengeData() {
        // Sample participant stats
        participantStats = [
            ParticipantStat(name: "Sarah Kim", progress: 0.85, value: Int(0.85 * 10000), isOnline: true),
            ParticipantStat(name: "You", progress: userProgress, value: Int(userProgress * 10000), isOnline: true),
            ParticipantStat(name: "Mike Chen", progress: 0.72, value: Int(0.72 * 10000), isOnline: false),
            ParticipantStat(name: "Emma Wilson", progress: 0.68, value: Int(0.68 * 10000), isOnline: true),
            ParticipantStat(name: "Alex Park", progress: 0.45, value: Int(0.45 * 10000), isOnline: false)
        ].sorted { $0.progress > $1.progress }
        
        // Sample activity
        challengeActivity = [
            ChallengeActivity(
                id: UUID(),
                participantName: "Sarah Kim",
                action: "updated progress",
                value: "8,500 steps",
                timestamp: "2 min ago",
                icon: "figure.walk"
            ),
            ChallengeActivity(
                id: UUID(),
                participantName: "Mike Chen",
                action: "joined challenge",
                value: "",
                timestamp: "1 hour ago",
                icon: "person.badge.plus"
            ),
            ChallengeActivity(
                id: UUID(),
                participantName: "Emma Wilson",
                action: "updated progress",
                value: "6,800 steps",
                timestamp: "3 hours ago",
                icon: "figure.walk"
            )
        ]
        
        // Set initial user progress if joined
        if isJoined {
            userProgress = 0.45 // Sample progress
        }
    }
    
    private func refreshData() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loadChallengeData()
    }
    
    private func joinChallenge() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isJoined = true
            userProgress = 0.0
        }
        
        successFeedback.notificationOccurred(.success)
        
        // Update participant stats
        if !participantStats.contains(where: { $0.name == "You" }) {
            participantStats.append(
                ParticipantStat(name: "You", progress: 0.0, value: 0, isOnline: true)
            )
            participantStats.sort { $0.progress > $1.progress }
        }
    }
    
    private func updateProgress() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            userProgress = min(userProgress + 0.1, 1.0)
        }
        
        lightFeedback.impactOccurred()
        
        // Update participant stats
        if let index = participantStats.firstIndex(where: { $0.name == "You" }) {
            participantStats[index].progress = userProgress
            participantStats[index].value = Int(userProgress * 10000)
            participantStats.sort { $0.progress > $1.progress }
        }
    }
    
    private func shareChallenge() {
    }
    
    private func getCurrentUserRank() -> Int {
        if let index = participantStats.firstIndex(where: { $0.name == "You" }) {
            return index + 1
        }
        return participantStats.count + 1
    }
    
    private func getGoalDescription() -> String {
        switch challengeType {
        case .steps:
            return "10000 steps"
        case .workout:
            return "10 exercises"
        case .water:
            return "2500ml water daily"
        }
    }
    
    private func getDurationDescription() -> String {
        return "Ends in 7 days"
    }
    
    private func getDifficultyColor() -> Color {
        return Color.orange // Medium difficulty
    }
    
    private func getChallengeRules() -> [String] {
        switch challengeType {
        case .steps:
            return [
                "Track your daily steps using your device",
                "Progress updates automatically throughout the day",
                "First participant to reach the goal wins",
                "Must maintain fair play - no cheating or manipulation"
            ]
        case .workout:
            return [
                "Complete the specified exercises within the time limit",
                "Log workouts manually with photo verification",
                "Quality over quantity - proper form required",
                "Take rest days as needed for recovery"
            ]
        case .water:
            return [
                "Track daily water intake",
                "Must reach goal for consecutive days",
                "Log intake throughout the day for accuracy",
                "Stay consistent to maintain your streak"
            ]
        }
    }
}


struct DetailChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(.caption2, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
    }
}

struct ChallengeDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(.caption, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct ParticipantPreviewCard: View {
    let name: String
    private let primaryWater = Color.blue
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(primaryWater.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text(String(name.prefix(1)))
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(primaryWater)
            }
            
            Text(name)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.adaptiveCardBackground.opacity(0.5))
        )
    }
}

struct LeaderboardRow: View {
    let participant: ParticipantStat
    let rank: Int
    let isCurrentUser: Bool
    private let primaryWater = Color.blue
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)
            }
            
            // Avatar and Name
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(participant.isOnline ? primaryWater.opacity(0.2) : Color.adaptiveCardBackground.opacity(0.8))
                        .frame(width: 40, height: 40)
                    
                    Text(String(participant.name.prefix(1)))
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(participant.isOnline ? primaryWater : .secondary)
                    
                    if participant.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .offset(x: 14, y: -14)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(participant.name)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(isCurrentUser ? .bold : .semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(participant.value)")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Progress
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(participant.progress * 100))%")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(primaryWater)
                
                ProgressView(value: participant.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryWater))
                    .frame(width: 60)
                    .scaleEffect(y: 1.5)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrentUser ? primaryWater.opacity(0.1) : Color.clear)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color.yellow
        case 2: return Color.gray
        case 3: return Color.orange
        default: return Color.blue
        }
    }
}

struct ActivityRow: View {
    let activity: ChallengeActivity
    private let primaryWater = Color.blue
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(primaryWater.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: activity.icon)
                    .font(.system(.caption, weight: .medium))
                    .foregroundColor(primaryWater)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(activity.participantName)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(activity.action)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if !activity.value.isEmpty {
                        Text("(\(activity.value))")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(primaryWater)
                    }
                }
                
                Text(activity.timestamp)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.primary.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}


struct ParticipantStat: Identifiable {
    let id = UUID()
    let name: String
    var progress: Double
    var value: Int
    let isOnline: Bool
}

struct ChallengeActivity: Identifiable {
    let id: UUID
    let participantName: String
    let action: String
    let value: String
    let timestamp: String
    let icon: String
}

#Preview {
    NavigationView {
        ChallengeDetailView()
            .environmentObject(NavigationCoordinator())
    }
}
