// ProfileSettingsView.swift
import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var notificationService: NotificationService
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
    @State private var showingNotificationTest = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Profile Section with standard iOS style
                    VStack(spacing: 16) {
                            // Profile Photo with iOS style
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.waterBlue,
                                                    Color.lightBlue
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                    
                                    // Camera icon overlay
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Circle()
                                                .fill(Color.waterBlue)
                                                .frame(width: 28, height: 28)
                                                .overlay(
                                                    Image(systemName: "camera.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white)
                                                )
                                                .offset(x: -8, y: -8)
                                        }
                                    }
                                }
                            }
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            // User Info with iOS style
                            VStack(spacing: 4) {
                                Text(username.isEmpty ? "User Name" : username)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(email.isEmpty ? "user@example.com" : email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        
                        // Account Information Section - iOS Style
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ACCOUNT INFORMATION")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                            }
                            
                            VStack(spacing: 0) {
                                // Username Field - iOS Style
                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.waterBlue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Username")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        TextField("Enter username", text: $username)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                                    .padding(.leading, 58)
                                
                                // Email Field - iOS Style (read-only)
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.waterBlue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Email")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text(email.isEmpty ? "user@example.com" : email)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 36)
                        
                        // Security Section - iOS Style
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SECURITY")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                            }
                            
                            VStack(spacing: 0) {
                                // New Password Field - iOS Style
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.waterBlue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("New Password")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        SecureField("Enter new password", text: $newPassword)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                                    .padding(.leading, 58)
                                
                                // Confirm Password Field - iOS Style
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.waterBlue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Confirm Password")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        SecureField("Confirm new password", text: $confirmPassword)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 36)
                        
                        // Preferences Section - iOS Style
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PREFERENCES")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                            }
                            
                            VStack(spacing: 0) {
                                // Push Notifications
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.waterBlue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Push Notifications")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Get workout reminders and updates")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $notificationsEnabled)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                                    .padding(.leading, 58)
                                
                                // Workout Suggestions
                                HStack(spacing: 12) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.waterBlue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Workout Suggestions")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Receive personalized workout recommendations")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $workoutSuggestionsEnabled)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                                    .padding(.leading, 58)
                                
                                // Face ID
                                HStack(spacing: 12) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 20))
                                        .foregroundColor(.waterBlue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Face ID")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Use Face ID for quick app access")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $faceIDEnabled)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                                    .padding(.leading, 58)
                                
                                // Test Notifications Button
                                Button(action: {
                                    showingNotificationTest = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "bell.badge.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.waterBlue)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Test Notifications")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Text("Preview notification types")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                                    .padding(.leading, 58)
                                
                                // Show App Guide Button
                                Button(action: {
                                    resetOnboarding()
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.waterBlue)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Show App Guide")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Text("View the onboarding tutorial again")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemGroupedBackground))
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 36)
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Buttons with iOS style
                        VStack(spacing: 16) {
                            // Save Changes Button
                            Button(action: {
                                saveUserChanges()
                            }) {
                                HStack(spacing: 12) {
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
                                            Color.waterBlue,
                                            Color.lightBlue
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.waterBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // Logout Button
                            Button(action: {
                                showingLogoutConfirmation = true
                            }) {
                                HStack(spacing: 12) {
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
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // Delete Account Button
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                HStack(spacing: 12) {
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
                                .cornerRadius(12)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 120) // Space for bottom navigation bar
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(nil) // Support system dark mode
        .navigationViewStyle(StackNavigationViewStyle())
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
        .sheet(isPresented: $showingNotificationTest) {
            NotificationTestView()
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
                .foregroundColor(.primary)
                .shadow(color: Color.primary.opacity(0.1), radius: 1, x: 0, y: 1)
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveCardBackground.opacity(0.95))
                .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 4)
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
            .background(Color.adaptiveTextFieldBackground)
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
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
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
