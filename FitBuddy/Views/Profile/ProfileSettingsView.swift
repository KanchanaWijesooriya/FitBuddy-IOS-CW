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
    @State private var showingNotificationSettings = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header Section
                    VStack(spacing: 8) {
                        // Profile Image
                        Button(action: { showingImagePicker = true }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.waterBlue, Color.waterBlue.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                
                                // Camera overlay - positioned more towards center
                                Circle()
                                    .fill(Color.waterBlue)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 22, y: 22)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // User info centered below profile image
                        VStack(spacing: 1) {
                            Text(username.isEmpty ? "User" : username)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(email.isEmpty ? "user@example.com" : email)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, -10)
                    .padding(.bottom, 10)
                    .background(Color(.systemGroupedBackground))
                    
                    VStack(spacing: 16) {
                        // Account Information Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Account Information")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                // Username Row
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.waterBlue)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Name")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        TextField("Enter your name", text: $username)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                // Email Row (Read-only)
                                HStack {
                                    Image(systemName: "envelope.circle.fill")
                                        .foregroundColor(.waterBlue)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
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
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        
                        // Security Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Security & Privacy")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                // Change Password
                                Button(action: {
                                    // Navigate to password change
                                }) {
                                    HStack {
                                        Image(systemName: "key.fill")
                                            .foregroundColor(.waterBlue)
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Change Password")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Text("Update your account password")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                // Face ID Toggle
                                HStack {
                                    Image(systemName: "faceid")
                                        .foregroundColor(.waterBlue)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Face ID")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Use Face ID for quick access")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $faceIDEnabled)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preferences")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                            
            VStack(spacing: 0) {
                // Notification Settings Button
                Button(action: { 
                    showingNotificationSettings = true
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.waterBlue)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notification Settings")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Manage motivation tips and reminders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                    .padding(.leading, 56)                                // Workout Suggestions Toggle
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.waterBlue)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Workout Suggestions")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Personalized recommendations")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $workoutSuggestionsEnabled)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        
                        // Support Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Support")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                // App Guide
                                Button(action: { resetOnboarding() }) {
                                    HStack {
                                        Image(systemName: "questionmark.circle.fill")
                                            .foregroundColor(.waterBlue)
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Show App Guide")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Text("View onboarding tutorial again")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        
                        // Account Actions Section
                        VStack(spacing: 12) {
                            // Save Changes
                            Button(action: { saveUserChanges() }) {
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.body)
                                        
                                        Text("Save Changes")
                                            .font(.body)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    
                                    Spacer()
                                }
                                .background(Color.waterBlue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Logout
                            Button(action: { showingLogoutConfirmation = true }) {
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.body)
                                        
                                        Text("Sign Out")
                                            .font(.body)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.red)
                                    .padding(.vertical, 16)
                                    
                                    Spacer()
                                }
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Delete Account
                            Button(action: { showingDeleteConfirmation = true }) {
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "trash.fill")
                                            .font(.body)
                                        
                                        Text("Delete Account")
                                            .font(.body)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.red)
                                    .padding(.vertical, 16)
                                    
                                    Spacer()
                                }
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                            .frame(height: 30)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile and Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
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
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .onAppear {
            loadUserData()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
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


struct PasswordChangeView: View {
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    SecureField("New Password", text: $newPassword)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Section {
                    Text("Password must be at least 8 characters long and contain a mix of letters, numbers, and special characters.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Handle password change logic here
                        dismiss()
                    }
                    .disabled(newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword)
                }
            }
        }
    }
}


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
                .foregroundColor(.waterBlue)
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
                    .stroke(Color.waterBlue.opacity(0.3), lineWidth: 1)
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
                .toggleStyle(SwitchToggleStyle(tint: .waterBlue))
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
            Circle()
                .fill(Color.waterBlue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.waterBlue)
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.waterBlue)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.waterBlue.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Modern toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .waterBlue))
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
                .environmentObject(NavigationCoordinator())
                .environmentObject(NotificationService.shared)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
