import SwiftUI

struct OnboardingCard {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String?
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
    
    // Apple Blue theme
    private let primaryAccent = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    // Onboarding cards data
    private let onboardingCards = [
        OnboardingCard(
            title: "Welcome to FitBuddy! 🎯",
            description: "Your personal fitness companion that helps you track workouts, monitor daily activities, and achieve your health goals. Let's explore what FitBuddy can do for you!",
            imageName: "figure.strengthtraining.traditional",
            type: .appIntro
        ),
        OnboardingCard(
            title: "Discover Workouts 💪",
            description: "Choose from various workout types including cardio, strength training, yoga, and more. Track your progress, burn calories, and build healthy habits with personalized recommendations.",
            imageName: "dumbbell.fill",
            type: .workoutTypes
        ),
        OnboardingCard(
            title: "Navigate Like a Pro 🧭",
            description: "🏠 Home: Your dashboard\n💪 Workout: Browse exercises\n📊 Status: Track progress\n👤 Profile: Manage settings\n\nTap the ? button anytime for help!",
            imageName: "questionmark.circle.fill",
            type: .navigationGuide
        )
    ]
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
            
            // Card container
            VStack(spacing: 0) {
                Spacer()
                
                // Main card
                VStack(spacing: 0) {
                    // Card content
                    cardContent
                    
                    // Navigation controls
                    navigationControls
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                .offset(x: dragOffset.width)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 100
                            
                            if value.translation.width > threshold && currentCardIndex > 0 {
                                // Swipe right - previous card
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentCardIndex -= 1
                                    dragOffset = .zero
                                }
                            } else if value.translation.width < -threshold && currentCardIndex < onboardingCards.count - 1 {
                                // Swipe left - next card
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentCardIndex += 1
                                    dragOffset = .zero
                                }
                            } else {
                                // Snap back
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentCardIndex)
    }
    
    private var cardContent: some View {
        VStack(spacing: 24) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.ultraThinMaterial))
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Card indicator dots
            HStack(spacing: 8) {
                ForEach(0..<onboardingCards.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentCardIndex ? primaryAccent : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentCardIndex ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentCardIndex)
                }
            }
            .padding(.top, -10)
            
            // Icon
            if let imageName = onboardingCards[currentCardIndex].imageName {
                Image(systemName: imageName)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(primaryAccent)
                    .frame(height: 80)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Title
            Text(onboardingCards[currentCardIndex].title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            
            // Description
            Text(onboardingCards[currentCardIndex].description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .padding(.bottom, 20)
    }
    
    private var navigationControls: some View {
        VStack(spacing: 16) {
            // Swipe indicator
            HStack(spacing: 4) {
                if currentCardIndex > 0 {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Swipe or tap to navigate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if currentCardIndex < onboardingCards.count - 1 {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                // Skip button
                if currentCardIndex < onboardingCards.count - 1 {
                    Button("Skip") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                    .font(.system(.body, design: .default, weight: .medium))
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Next/Done button
                Button(action: {
                    if currentCardIndex < onboardingCards.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentCardIndex += 1
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentCardIndex < onboardingCards.count - 1 ? "Next" : "Get Started")
                            .font(.system(.body, design: .default, weight: .semibold))
                        
                        if currentCardIndex < onboardingCards.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(primaryAccent)
                    )
                }
                .scaleEffect(currentCardIndex == onboardingCards.count - 1 ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: currentCardIndex)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    RoundedRectangle(cornerRadius: 20)
                        .padding(.top, -100)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        
        OnboardingHelpView(isPresented: .constant(true))
    }
}
