// ProfileSettingsView.swift
import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var username: String = "Chanuka Wijesooriya"
    @State private var email: String = "chanuka@example.com"
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var notificationsEnabled: Bool = true
    @State private var workoutSuggestionsEnabled: Bool = true
    @State private var faceIDEnabled: Bool = false
    @State private var showingImagePicker = false
    @State private var showingSaveAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Modern Navigation Header without back button for main page
                HStack {
                    Spacer()
                    
                    Text("Profile Settings")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .safeAreaPadding(.top)
                .padding(.bottom, 16)
                .background(Color.clear)
                
                // Content with modern iOS styling
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Profile Section
                        VStack(spacing: 20) {
                            // Profile Photo with modern styling
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                                    Color(red: 0.5, green: 0.8, blue: 0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                    
                                    // Camera icon overlay
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Circle()
                                                .fill(Color(red: 0.7, green: 1.0, blue: 0.3))
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Image(systemName: "camera.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.black)
                                                )
                                                .offset(x: -8, y: -8)
                                        }
                                    }
                                }
                            }
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            
                            // User Info
                            VStack(spacing: 6) {
                                Text(username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Settings Sections with modern cards
                        VStack(spacing: 16) {
                            // Account Information Section
                            SettingsCard(title: "Account Information") {
                                VStack(spacing: 16) {
                                    // Username Field
                                    ModernTextField(
                                        title: "Username",
                                        text: $username,
                                        icon: "person.fill"
                                    )
                                    
                                    // Email Field (read-only)
                                    VStack(alignment: .leading, spacing: 8) {
                                        Label("Email", systemImage: "envelope.fill")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                            .fontWeight(.medium)
                                        
                                        Text(email)
                                            .font(.body)
                                            .foregroundColor(.black.opacity(0.7))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            
                            // Security Section
                            SettingsCard(title: "Security") {
                                VStack(spacing: 16) {
                                    ModernTextField(
                                        title: "New Password",
                                        text: $newPassword,
                                        icon: "lock.fill",
                                        isSecure: true
                                    )
                                    
                                    ModernTextField(
                                        title: "Confirm Password",
                                        text: $confirmPassword,
                                        icon: "lock.fill",
                                        isSecure: true
                                    )
                                }
                            }
                            
                            // Preferences Section
                            SettingsCard(title: "Preferences") {
                                VStack(spacing: 16) {
                                    ModernToggleRow(
                                        title: "Push Notifications",
                                        subtitle: "Get workout reminders and updates",
                                        icon: "bell.fill",
                                        isOn: $notificationsEnabled
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                    
                                    ModernToggleRow(
                                        title: "Workout Suggestions",
                                        subtitle: "Receive personalized workout recommendations",
                                        icon: "lightbulb.fill",
                                        isOn: $workoutSuggestionsEnabled
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                    
                                    ModernToggleRow(
                                        title: "Face ID",
                                        subtitle: "Use Face ID for quick app access",
                                        icon: "faceid",
                                        isOn: $faceIDEnabled
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Save Changes Button
                            Button(action: {
                                showingSaveAlert = true
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                    Text("Save Changes")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.7, green: 1.0, blue: 0.3),
                                            Color(red: 0.6, green: 0.9, blue: 0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // Logout Button
                            Button(action: {
                                // Logout logic
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "power")
                                        .font(.title3)
                                    Text("Logout")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // Increased padding for bottom navigation bar
                    }
                }
            }
        }
        .background(
            ZStack {
                // Background image
                Image("profile_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                
                // Gradient overlay
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
        .navigationBarHidden(true)
        .alert("Settings Saved", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text("Your profile settings have been updated successfully.")
        }
        .sheet(isPresented: $showingImagePicker) {
            // Image picker would go here
            Text("Image Picker")
        }
    }
}

// MARK: - Modern Components

struct SettingsCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .shadow(color: .white.opacity(0.3), radius: 1, x: 0, y: 1)
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                .fontWeight(.medium)
            
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .font(.body)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct ModernToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with themed background
            Circle()
                .fill(Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Modern toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.7, green: 1.0, blue: 0.3)))
                .scaleEffect(0.9)
        }
        .padding(.vertical, 4)
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettingsView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
