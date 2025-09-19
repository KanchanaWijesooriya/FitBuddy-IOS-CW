// OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var timer: Timer?
    @State private var navigateToLogin = false
    
    let images = ["onboarding-screen", "onboarding-screen-2", "onboarding-screen-3"]
    let titles = [
        ("Wherever You Are", "Health Is Number One"),
        ("Track Your Progress", "Every Step Counts"),
        ("Stay Motivated", "Achieve Your Goals")
    ]
    let descriptions = [
        "There is no instant way to a healthy life",
        "Monitor your daily activities and build healthy habits",
        "Join challenges and stay committed to your fitness journey"
    ]
    
    var body: some View {
        ZStack {
            // Full Screen Background Image - 100% coverage including status bar and home indicator
            TabView(selection: $currentPage) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(.all)
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .white.opacity(0.4), location: 0.15),
                                .init(color: .white.opacity(0.5), location: 0.3),
                                .init(color: .white.opacity(0.75), location: 0.45),
                                .init(color: .white.opacity(0.85), location: 0.6),
                                .init(color: .white.opacity(0.95), location: 0.75),
                                .init(color: .white, location: 0.85)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .ignoresSafeArea(.all)
            }
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text(titles[currentPage].0)
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundStyle(.black)
                            .animation(.easeInOut(duration: 0.5), value: currentPage)
                        
                        HStack(spacing: 0) {
                            Text(titles[currentPage].1.contains("Number One") ? "Health Is " : 
                                 titles[currentPage].1.contains("Counts") ? "Every Step " :
                                 "Achieve Your ")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundStyle(.black)
                            Text(titles[currentPage].1.contains("Number One") ? "Number One" : 
                                 titles[currentPage].1.contains("Counts") ? "Counts" :
                                 "Goals")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundStyle(Color(red: 0.0, green: 0.478, blue: 1.0)) // Apple Blue
                        }
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                        
                        Text(descriptions[currentPage])
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.3)) // Dark gray
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .animation(.easeInOut(duration: 0.5), value: currentPage)
                        
                        // Progress indicator
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Rectangle()
                                    .fill(index == currentPage ? Color(red: 0.0, green: 0.478, blue: 1.0) : Color(red: 0.4, green: 0.4, blue: 0.4).opacity(0.4)) // Apple Blue and dark gray
                                    .frame(width: index == currentPage ? 20 : 8, height: 4)
                                    .cornerRadius(2)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        .padding(.vertical, 16)
                        
                        // Get Started Button
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(.black)
                                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            startAutoSlideTimer()
        }
        .onDisappear {
            stopAutoSlideTimer()
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            NavigationView {
                LoginView()
            }
        }
    }
    
    private func startAutoSlideTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = (currentPage + 1) % images.count
            }
        }
    }
    
    private func stopAutoSlideTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
