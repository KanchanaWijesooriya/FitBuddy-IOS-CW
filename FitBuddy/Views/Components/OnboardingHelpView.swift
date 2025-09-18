import SwiftUI

struct OnboardingCard {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let type: OnboardingCardType
}

enum OnboardingCardType {
    case appIntro
    case workoutTypes
    case navigationGuide
}

struct OnboardingHelpView: View {
    @Binding var isPresented: Bool
    @State private var currentCardIndex = 0
    @State private var dragOffset: CGSize = .zero
    
    // App's blue theme - using the water blue theme
    private let primaryAccent = Color.waterBlue
    private let lightBlue = Color.lightBlue
    private let darkBlue = Color.darkBlue
    
    // Enhanced onboarding cards with modern content - Apple style
    private let onboardingCards = [
        OnboardingCard(
            title: "Welcome to FitBuddy!",
            description: "Your personal fitness companion that helps you track workouts, monitor daily activities, and achieve your health goals. Let's explore what FitBuddy can do for you!",
            iconName: "figure.strengthtraining.traditional",
            type: .appIntro
        ),
        OnboardingCard(
            title: "Navigate Like a Pro",
            description: "Home: Your dashboard\nWorkout: Browse exercises\nStatus: Track progress\nProfile: Manage settings\n\nTap the ? button anytime for help!",
            iconName: "questionmark.circle.fill",
            type: .navigationGuide
        ),
        OnboardingCard(
            title: "Track Your Fitness Journey",
            description: "Monitor your daily activities, water intake, and workout progress. Set goals, track achievements, and build healthy habits with personalized insights.",
            iconName: "chart.line.uptrend.xyaxis",
            type: .workoutTypes
        )
    ]
    
    var body: some View {
        ZStack {
            // Clean Apple-style background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            // Bottom sheet container
            VStack(spacing: 0) {
                Spacer()
                
                // Modern Apple-style bottom sheet
                VStack(spacing: 0) {
                    // Drag handle
                    dragHandle
                    
                    // Apple-style card content
                    appleStyleCardContent
                    
                    // Apple-style navigation controls
                    appleStyleNavigationControls
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)
                )
                .offset(x: dragOffset.width)
                .scaleEffect(1.0 - abs(dragOffset.width) * 0.0003)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring()) {
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 120
                            
                            if value.translation.width > threshold && currentCardIndex > 0 {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentCardIndex -= 1
                                    dragOffset = .zero
                                }
                            } else if value.translation.width < -threshold && currentCardIndex < onboardingCards.count - 1 {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentCardIndex += 1
                                    dragOffset = .zero
                                }
                            } else {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentCardIndex)
    }
    
    // Drag handle for bottom sheet
    private var dragHandle: some View {
        VStack(spacing: 0) {
            // Visual drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 6)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
    }
    
    private var appleStyleCardContent: some View {
        VStack(spacing: 0) {
            // Progress indicators at the top
            HStack(spacing: 8) {
                ForEach(0..<onboardingCards.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentCardIndex ? primaryAccent : Color(.systemGray4))
                        .frame(width: index == currentCardIndex ? 20 : 6, height: 6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentCardIndex)
                }
            }
            .padding(.top, 16) // Increased from 8
            .padding(.bottom, 32) // Increased from 20
            
            // Large Icon with Apple-style design or navigation guide
            if onboardingCards[currentCardIndex].type == .navigationGuide {
                navigationGuideContent
            } else {
                ZStack {
                    Circle()
                        .fill(primaryAccent.opacity(0.1))
                        .frame(width: 120, height: 120) // Increased from 100
                    
                    Image(systemName: onboardingCards[currentCardIndex].iconName)
                        .font(.system(size: 50, weight: .medium)) // Increased from 40
                        .foregroundColor(primaryAccent)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
                .padding(.bottom, 32) // Increased from 24
            }
            
            // Title and Description
            if onboardingCards[currentCardIndex].type != .navigationGuide {
                VStack(spacing: 16) { // Increased from 12
                    Text(onboardingCards[currentCardIndex].title)
                        .font(.system(size: 32, weight: .bold, design: .default)) // Increased from 28
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                    Text(onboardingCards[currentCardIndex].description)
                        .font(.system(size: 17, weight: .regular)) // Increased from 16
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4) // Increased from 3
                        .padding(.horizontal, 28) // Increased from 24
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                .padding(.bottom, 32) // Increased from 20
            }
            
        }
    }
    
    private var navigationGuideContent: some View {
        VStack(spacing: 20) { // Increased from 16
            // Title and Description at the top
            VStack(spacing: 14) { // Increased from 10
                Text("Navigate Like a Pro")
                    .font(.system(size: 28, weight: .bold, design: .default)) // Increased from 24
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Master app navigation with these key tabs")
                    .font(.system(size: 17, weight: .regular)) // Increased from 15
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24) // Increased from 20
            }
            
            // Navigation list with vector icons - vertical layout like Apple style
            VStack(spacing: 12) { // Increased from 8
                // Home tab
                NavigationListItem(
                    icon: "house.fill",
                    title: "Home",
                    description: "Your dashboard",
                    color: primaryAccent
                )
                
                // Workout tab
                NavigationListItem(
                    icon: "figure.strengthtraining.traditional",
                    title: "Workout",
                    description: "Browse exercises",
                    color: primaryAccent
                )
                
                // Status tab
                NavigationListItem(
                    icon: "chart.bar.fill",
                    title: "Status",
                    description: "Track progress",
                    color: primaryAccent
                )
                
                // Profile tab
                NavigationListItem(
                    icon: "person.circle.fill",
                    title: "Profile",
                    description: "Manage settings",
                    color: primaryAccent
                )
            }
            .padding(.horizontal, 20) // Increased from 16
            
            // Help tip
            HStack(spacing: 8) { // Increased from 6
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 16, weight: .medium)) // Increased from 12
                    .foregroundColor(primaryAccent)
                
                Text("Tap the ? button anytime for help!")
                    .font(.system(size: 15, weight: .medium)) // Increased from 12
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20) // Increased from 16
        }
        .padding(.bottom, 24) // Increased from 16
    }
    
    private var appleStyleNavigationControls: some View {
        VStack(spacing: 0) {
            // Divider
            Divider()
                .padding(.horizontal, 20)
            
            // Navigation area
            VStack(spacing: 16) { // Increased from 12
                // Swipe indicator
                HStack(spacing: 4) {
                    if currentCardIndex > 0 {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Swipe or tap to navigate")
                        .font(.system(size: 15, weight: .regular)) // Increased from 14
                        .foregroundColor(.secondary)
                    
                    if currentCardIndex < onboardingCards.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 12) // Increased from 8
                
                // Action buttons
                HStack(spacing: 16) { // Increased from 12
                    // Skip button
                    if currentCardIndex < onboardingCards.count - 1 {
                        Button("Skip") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }
                        .font(.system(size: 17, weight: .regular)) // Increased from 16
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Primary action button
                    Button(action: {
                        if currentCardIndex < onboardingCards.count - 1 {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentCardIndex += 1
                            }
                        } else {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }
                    }) {
                        HStack(spacing: 8) { // Increased from 6
                            Text(currentCardIndex < onboardingCards.count - 1 ? "Continue" : "Get Started")
                                .font(.system(size: 17, weight: .semibold)) // Increased from 16
                            
                            if currentCardIndex == onboardingCards.count - 1 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold)) // Increased from 14
                            } else {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold)) // Increased from 14
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50) // Increased from 44
                        .background(
                            RoundedRectangle(cornerRadius: 14) // Increased from 12
                                .fill(primaryAccent)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, max(UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0, 20)) // Increased from 16
            }
        }
        .background(Color(.systemBackground))
    }
}

struct NavigationListItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) { // Increased from 12
            // Icon container with consistent border radius
            ZStack {
                RoundedRectangle(cornerRadius: 12) // Increased from 10
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50) // Increased from 40x40
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium)) // Increased from 20
                    .foregroundColor(color)
            }
            
            // Text content aligned to the left
            VStack(alignment: .leading, spacing: 2) { // Increased from 1
                Text(title)
                    .font(.system(size: 18, weight: .semibold)) // Increased from 16
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular)) // Increased from 13
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14) // Increased from 10
        .padding(.vertical, 10) // Increased from 6
        .background(
            RoundedRectangle(cornerRadius: 12) // Increased from 10
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.85)
            .ignoresSafeArea()
        
        OnboardingHelpView(isPresented: .constant(true))
    }
}
