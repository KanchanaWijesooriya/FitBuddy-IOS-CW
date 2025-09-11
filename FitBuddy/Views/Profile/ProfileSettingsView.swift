// ProfileSettingsView.swift
import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var notificationsEnabled: Bool = true
    @State private var workoutSuggestionsEnabled: Bool = true
    @State private var faceIDEnabled: Bool = false
    @State private var showingImagePicker = false
    @State private var showingSaveAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var showingLogoutConfirmation = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
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
                                                    .blue,
                                                    .blue.opacity(0.8)
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
                                                .fill(.blue)
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Image(systemName: "camera.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.white)
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
                                    .foregroundColor(.black)
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
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                            .fontWeight(.medium)
                                        
                                        Text(email)
                                            .font(.body)
                                            .foregroundColor(.black)
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
                                    BlackTextToggleRow(
                                        title: "Push Notifications",
                                        subtitle: "Get workout reminders and updates",
                                        icon: "bell.fill",
                                        isOn: $notificationsEnabled
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                    
                                    BlackTextToggleRow(
                                        title: "Workout Suggestions",
                                        subtitle: "Receive personalized workout recommendations",
                                        icon: "lightbulb.fill",
                                        isOn: $workoutSuggestionsEnabled
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                    
                                    BlackTextToggleRow(
                                        title: "Face ID",
                                        subtitle: "Use Face ID for quick app access",
                                        icon: "faceid",
                                        isOn: $faceIDEnabled
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                    
                                    // Reset Onboarding Button
                                    Button(action: {
                                        resetOnboarding()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "questionmark.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.blue)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Show App Guide")
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                
                                                Text("View the onboarding tutorial again")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Save Changes Button
                            Button(action: {
                                saveUserChanges()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                    Text("Save Changes")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            .blue,
                                            .blue.opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // Logout Button
                            Button(action: {
                                showingLogoutConfirmation = true
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
                            
                            // Delete Account Button
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "trash.fill")
                                        .font(.title3)
                                    Text("Delete Account")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.red, Color.red.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // Increased padding for bottom navigation bar
                    }
                }
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .alert("Settings Saved", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text("Your profile settings have been updated successfully.")
        }
        .alert("Logout", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                performAccountDeletion()
            }
        } message: {
            Text("Are you sure you want to permanently delete your account? This action cannot be undone and will remove all your data.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingImagePicker) {
            // Image picker would go here
            Text("Image Picker")
        }
        .onAppear {
            loadUserData()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadUserData() {
        if let user = authService.currentUser {
            username = user.name
            email = user.email ?? ""
            faceIDEnabled = user.isFaceIDEnabled
            print("Loaded Face ID setting from user profile: \(faceIDEnabled)")
        }
        
        // Also sync with current auth service state
        let currentFaceIDState = authService.isFaceIDEnabled()
        if faceIDEnabled != currentFaceIDState {
            faceIDEnabled = currentFaceIDState
            print("Synced Face ID setting with auth service: \(faceIDEnabled)")
        }
    }
    
    // MARK: - Action Methods
    
    private func saveUserChanges() {
        guard let currentUser = authService.currentUser else { return }
        
        // Handle Face ID setting change
        let currentFaceIDEnabled = authService.isFaceIDEnabled()
        if faceIDEnabled != currentFaceIDEnabled {
            print("Face ID setting changed: \(currentFaceIDEnabled) -> \(faceIDEnabled)")
            authService.setFaceIDEnabled(faceIDEnabled)
        }
        
        // Create updated user object
        let updatedUser = User(
            id: currentUser.id,
            uid: currentUser.uid,
            name: username,
            email: email,
            age: currentUser.age,
            weight: currentUser.weight,
            dailyStepGoal: currentUser.dailyStepGoal,
            dailyWaterGoal: currentUser.dailyWaterGoal,
            profileImageURL: currentUser.profileImageURL,
            createdAt: currentUser.createdAt,
            isFaceIDEnabled: faceIDEnabled
        )
        
        // Update user profile in Firebase
        authService.updateUserProfile(updatedUser) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showingSaveAlert = true
                case .failure(let error):
                    self.errorMessage = "Failed to save changes: \(error.localizedDescription)"
                    self.showingErrorAlert = true
                }
            }
        }
    }
    
    private func performLogout() {
        authService.signOut()
    }
    
    private func performAccountDeletion() {
    guard authService.currentUser != nil else { return }
        
        authService.deleteAccount { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    // Account deletion successful, user will be automatically signed out
                    print("Account deleted successfully: \(message)")
                case .failure(let error):
                    // Show error alert
                    self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    self.showingErrorAlert = true
                    print("Failed to delete account: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        
        // Show a confirmation that onboarding will appear next time they visit home
        let alert = UIAlertController(
            title: "App Guide Reset",
            message: "The onboarding tutorial will show again the next time you visit the home screen.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
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
                .font(.caption2)
                .foregroundColor(.blue)
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
                    .stroke(.blue.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct BlackTextToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with themed background
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                )
            
            // Text content with black text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Modern toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .scaleEffect(0.9)
        }
        .padding(.vertical, 4)
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
                .fill(.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.blue.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Modern toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .scaleEffect(0.9)
        }
        .padding(.vertical, 4)
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettingsView()
                .environmentObject(AuthService.shared)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
