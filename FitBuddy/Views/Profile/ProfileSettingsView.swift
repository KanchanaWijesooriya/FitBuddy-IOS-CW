// ProfileSettingsView.swift
import SwiftUI

struct ProfileSettingsView: View {
    @State private var username: String = "Chanuka Wijesooriya"
    @State private var email: String = "chanuka@example.com"
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var notificationsEnabled: Bool = true
    @State private var workoutSuggestionsEnabled: Bool = true
    @State private var faceIDEnabled: Bool = false
    
    var body: some View {
            VStack(spacing: 0) {
                // Fixed Navigation Bar (centered title, iOS standard)
                HStack {
                    Spacer()
                    Text("Profile Settings")
                        .font(.system(.headline, design: .default))
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(height: 44)
                .background(Color(.systemBackground))
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Photo
                        VStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                .padding(.top, 32)
                            Text("Change Photo")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                        }
                        // Email (label and value, two left-aligned rows, full width)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(email)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        // Username
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Username")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Username", text: $username)
                                .font(.body)
                                .textFieldStyle(.roundedBorder)
                        }
                        // Change Password
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Change Password")
                                .font(.caption)
                                .foregroundColor(.gray)
                            SecureField("New Password", text: $newPassword)
                                .font(.body)
                                .textFieldStyle(.roundedBorder)
                            SecureField("Confirm Password", text: $confirmPassword)
                                .font(.body)
                                .textFieldStyle(.roundedBorder)
                        }
                        // Notification Option
                        HStack {
                            Text("Enable Notifications")
                                .font(.body)
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.7, green: 1.0, blue: 0.3)))
                        }
                        // Workout Suggestion Option
                        HStack {
                            Text("Enable Workout Suggestions")
                                .font(.body)
                            Spacer()
                            Toggle("", isOn: $workoutSuggestionsEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.7, green: 1.0, blue: 0.3)))
                        }
                        // Face ID Option
                        HStack {
                            Text("Enable Face ID")
                                .font(.body)
                            Spacer()
                            Toggle("", isOn: $faceIDEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.7, green: 1.0, blue: 0.3)))
                        }
                        // Save Button
                        Button(action: {
                            // Save profile settings logic here
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                                .foregroundColor(.black)
                                .cornerRadius(16)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                // Bottom Navigation Bar (same as Dashboard)
                HStack {
                    Spacer()
                    navBarItem(icon: "house.fill", label: "Home", isActive: false)
                    Spacer()
                    navBarItem(icon: "bolt.fill", label: "Challenges", isActive: false)
                    Spacer()
                    navBarItem(icon: "chart.bar.fill", label: "Progress", isActive: false)
                    Spacer()
                    navBarItem(icon: "person.fill", label: "Profile", isActive: true)
                    Spacer()
                }
                .frame(height: 64)
                .background(RoundedRectangle(cornerRadius: 24).fill(Color(.black)))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
    }

// Bottom Navigation Bar Item (must be outside body closure)
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

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
    }
}
