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
    
    // Enhanced onboarding cards with modern content
    private let onboardingCards = [
        OnboardingCard(
            title: "Welcome to FitBuddy!",
            description: "Your personal fitness companion that helps you track workouts, monitor daily activities, and achieve your health goals. Let's explore what FitBuddy can do for you!",
            iconName: "figure.strengthtraining.traditional",
            type: .appIntro
        ),
        OnboardingCard(
            title: "Navigate Like a Pro",
            description: "🏠 Home: Your dashboard\n💪 Workout: Browse exercises\n📊 Status: Track progress\n👤 Profile: Manage settings\n\nTap the ? button anytime for help!",
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
            // Modern background with subtle gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.75),
                    Color.black.opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isPresented = false
                }
            }
            
            // Enhanced card container
            VStack(spacing: 0) {
                Spacer()
                
                // Main modern card
                VStack(spacing: 0) {
                    // Enhanced card content
                    modernCardContent
                    
                    // Enhanced navigation controls
                    modernNavigationControls
                }
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.25), radius: 30, x: 0, y: 15)
                        .shadow(color: primaryAccent.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
                .offset(x: dragOffset.width)
                .scaleEffect(1.0 - abs(dragOffset.width) * 0.0005)
                .rotation3DEffect(
                    .degrees(dragOffset.width * 0.05),
                    axis: (x: 0, y: 1, z: 0)
                )
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
                                // Swipe right - previous card
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentCardIndex -= 1
                                    dragOffset = .zero
                                }
                            } else if value.translation.width < -threshold && currentCardIndex < onboardingCards.count - 1 {
                                // Swipe left - next card
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentCardIndex += 1
                                    dragOffset = .zero
                                }
                            } else {
                                // Snap back with spring animation
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
                
                Spacer()
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentCardIndex)
    }
    
    private var modernCardContent: some View {
        VStack(spacing: 32) {
            // Enhanced header with close button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 28)
            
            // Modern progress indicator
            HStack(spacing: 6) {
                ForEach(0..<onboardingCards.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index == currentCardIndex ? primaryAccent : Color.secondary.opacity(0.3))
                        .frame(width: index == currentCardIndex ? 24 : 8, height: 4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentCardIndex)
                }
            }
            .padding(.top, -16)
            
            // Enhanced icon with gradient background
            ZStack {
                // Icon background circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                primaryAccent.opacity(0.2),
                                lightBlue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: primaryAccent.opacity(0.2), radius: 15, x: 0, y: 8)
                
                // Main icon
                Image(systemName: onboardingCards[currentCardIndex].iconName)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [primaryAccent, darkBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
            .scaleEffect(currentCardIndex == 0 ? 1.05 : 1.0)
            
            VStack(spacing: 20) {
                // Enhanced title
                Text(onboardingCards[currentCardIndex].title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                // Enhanced description
                Text(onboardingCards[currentCardIndex].description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .padding(.bottom, 32)
    }
    
    private var modernNavigationControls: some View {
        VStack(spacing: 24) {
            // Enhanced swipe indicator
            HStack(spacing: 6) {
                if currentCardIndex > 0 {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
                
                Text("Swipe or tap to navigate")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                if currentCardIndex < onboardingCards.count - 1 {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
            }
            .padding(.top, 8)
            
            // Enhanced action buttons
            HStack(spacing: 20) {
                // Skip button with modern styling
                if currentCardIndex < onboardingCards.count - 1 {
                    Button("Skip") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 60)
                }
                
                Spacer()
                
                // Enhanced Next/Done button with modern Apple styling
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
                    HStack(spacing: 10) {
                        Text(currentCardIndex < onboardingCards.count - 1 ? "Next" : "Get Started")
                            .font(.system(size: 17, weight: .semibold))
                        
                        if currentCardIndex < onboardingCards.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [primaryAccent, darkBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: primaryAccent.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
                }
                .scaleEffect(currentCardIndex == onboardingCards.count - 1 ? 1.08 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentCardIndex)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 32)
        }
        .background(
            Rectangle()
                .fill(.thickMaterial)
                .mask(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .padding(.top, -60)
                )
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: -1)
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        OnboardingHelpView(isPresented: .constant(true))
    }
}
