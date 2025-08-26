// DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @State private var searchText = ""
    // Example user data
    let userName = "Chanuka Wijesooriya"
    let greeting = "Good Morning 🔥"
    
    // Workout and Plan models
    struct Workout: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let calories: String
        let duration: String
        let imageName: String
    }
    struct Plan: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let level: String
        let description: String
        let progress: Double
        let imageName: String
    }
    // Example workouts
    let popularWorkouts: [Workout] = [
        Workout(title: "Lower Body Training", calories: "500 Kcal", duration: "50 Min", imageName: "onboarding-screen"),
        Workout(title: "Handstand Training", calories: "600 Kcal", duration: "40 Min", imageName: "onboarding-screen-2")
    ]
    let todayPlan: [Plan] = [
        Plan(title: "Push Up", level: "Intermediate", description: "100 Push up a day", progress: 0.45, imageName: "onboarding-screen-3"),
        Plan(title: "Sit Up", level: "Beginner", description: "20 Sit up a day", progress: 0.75, imageName: "onboarding-screen"),
        Plan(title: "Knee Push Up", level: "Beginner", description: "10 Knee Push up a day", progress: 0.2, imageName: "onboarding-screen-2")
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                // Top Greeting & Name with profile photo
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    // Profile photo icon
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(.systemGray3))
                        .padding(.trailing, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                Spacer(minLength: 12)
                // Apple native search bar style
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText)
                        .foregroundColor(.primary)
                    Button(action: {
                        // Future: trigger SiriKit voice search
                    }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(Color(.systemGray3)) // placeholder grey
                            .opacity(0.8)
                    }
                }
                .padding(10)
                .background(Color(.systemGray5).opacity(0.8))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                Spacer(minLength: 12)
                
                // Popular Workouts
                VStack(alignment: .leading, spacing: 8) {
                    Text("Popular Workouts")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.leading, 4)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(popularWorkouts) { workout in
                                ZStack(alignment: .bottomLeading) {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(.systemGray5).opacity(0.7))
                                        .frame(width: 200, height: 120)
                                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                    // Workout image with black opacity overlay
                                    Image(workout.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                    Rectangle()
                                        .fill(Color.black.opacity(0.45))
                                        .frame(width: 200, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(workout.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                        HStack(spacing: 12) {
                                            Label(workout.calories, systemImage: "flame.fill")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                            Label(workout.duration, systemImage: "clock.fill")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(12)
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.8))
                                            .frame(width: 36, height: 36)
                                            .overlay(Image(systemName: "play.fill")
                                                .foregroundColor(.black))
                                            .padding(12)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Today Plan
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today Plan")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.leading, 4)
                    ForEach(todayPlan) { plan in
                        HStack(spacing: 12) {
                            Image(plan.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(plan.title)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text(plan.level)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                }
                                Text(plan.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                // Progress Bar
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(red: 0.7, green: 1.0, blue: 0.3))
                                        .frame(width: CGFloat(plan.progress) * 180, height: 10)
                                }
                                .frame(width: 180)
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                // Status & Challenge cards stretch to content area edges
                HStack(spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemGray5).opacity(0.7))
                            .frame(maxWidth: .infinity, maxHeight: 140)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        Image("status-image")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        Rectangle()
                            .fill(Color.black.opacity(0.45))
                            .frame(maxWidth: .infinity, maxHeight: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        Text("Status")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.35))
                            .cornerRadius(10)
                            .padding([.leading, .bottom], 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 140)
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemGray5).opacity(0.7))
                            .frame(maxWidth: .infinity, maxHeight: 140)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        Image("challenge-image")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        Rectangle()
                            .fill(Color.black.opacity(0.45))
                            .frame(maxWidth: .infinity, maxHeight: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        Text("Go to Challenge")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.35))
                            .cornerRadius(10)
                            .padding([.leading, .bottom], 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 140)
                }
                .frame(height: 140)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                Spacer()
                // Bottom Navigation Bar
                HStack {
                    Spacer()
                    navBarItem(icon: "house.fill", label: "Home", isActive: true)
                    Spacer()
                    navBarItem(icon: "bolt.fill", label: "Challenges", isActive: false)
                    Spacer()
                    navBarItem(icon: "chart.bar.fill", label: "Progress", isActive: false)
                    Spacer()
                    navBarItem(icon: "person.fill", label: "Profile", isActive: false)
                    Spacer()
                }
                .frame(height: 64)
                .background(RoundedRectangle(cornerRadius: 24).fill(Color(.black)))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
    }
    
    // Navigation Bar Item
    @ViewBuilder
    func navBarItem(icon: String, label: String, isActive: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isActive ? Color(red: 0.7, green: 1.0, blue: 0.3) : .white)
            Text(label)
                .font(.caption2)
                .foregroundColor(isActive ? Color(red: 0.7, green: 1.0, blue: 0.3) : .white)
        }
        .padding(.vertical, 4)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
