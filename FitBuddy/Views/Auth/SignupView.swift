// SignupView.swift
import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var acceptTerms = false
    @State private var signupSuccessful = false
    @State private var showSuccessNotification = false
    
    @EnvironmentObject var authService: AuthService
    
    // Haptic feedback
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // App theme colors - Using water blue hydration theme
    private let primaryAccent = Color.waterBlue // Water blue
    private let stepBlue = Color.lightBlue // Light blue variant
    private let secondaryBlue = Color.darkBlue // Darker variant of blue
    private let lightBlue = Color.hydrationTeal // Hydration teal
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Flexible top spacer to center content
                        Spacer()
                            .frame(minHeight: geometry.safeAreaInsets.top + 10)
                        
                        logoSection
                        
                        Spacer()
                            .frame(height: 20)
                        
                        signupFormSection
                        
                        Spacer()
                            .frame(height: 20)
                        
                        bottomLoginSection(geometry: geometry)
                        
                        // Flexible bottom spacer to center content
                        Spacer()
                            .frame(minHeight: 20)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(backgroundView)
            .navigationBarHidden(true)
            
            // Top Success Notification
            if showSuccessNotification {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                        
                        Text("Account created successfully!")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showSuccessNotification = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .zIndex(999)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Registration"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - View Components
    
    private var logoSection: some View {
        VStack(spacing: 15) {
            // App Logo with your original green gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                primaryAccent,      // Apple blue
                                lightBlue,         // Lighter variant  
                                secondaryBlue      // Darker variant
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: primaryAccent.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Welcome text
            VStack(spacing: 8) {
                Text("Join FitBuddy")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [primaryAccent, Color.vibrantCyan.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Create your account to start your fitness journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var signupFormSection: some View {
        VStack(spacing: 20) {
            inputFields
            termsSection
            signupButton
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 28)
        .background(formBackground)
        .padding(.horizontal, 24)
    }
    
    private var inputFields: some View {
        VStack(spacing: 16) {
            nameField
            emailField
            passwordField
            confirmPasswordField
        }
    }
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Full Name")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField("Enter your full name", text: $name)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.primary)
                    .textContentType(.name)
                    .placeholder(when: name.isEmpty) {
                        Text("Enter your full name")
                            .foregroundColor(.secondary)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(inputFieldBackground)
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField("Enter your email", text: $email)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.primary)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .placeholder(when: email.isEmpty) {
                        Text("Enter your email")
                            .foregroundColor(.secondary)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(inputFieldBackground)
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                SecureField("Create a password", text: $password)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.primary)
                    .textContentType(.newPassword)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(inputFieldBackground)
        }
    }
    
    private var confirmPasswordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confirm Password")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                SecureField("Confirm your password", text: $confirmPassword)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.primary)
                    .textContentType(.newPassword)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(inputFieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        password.isEmpty || confirmPassword.isEmpty ? Color.clear :
                        (password == confirmPassword ? primaryAccent.opacity(0.5) : Color.red.opacity(0.5)),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private var termsSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                lightFeedback.impactOccurred()
                acceptTerms.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if acceptTerms {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(primaryAccent)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("I agree to the Terms of Service and Privacy Policy")
                    .font(.subheadline)
                    .foregroundColor(.primary.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
    
    private var signupButton: some View {
        Button(action: {
            signup()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Text(isLoading ? "CREATING ACCOUNT..." : "CREATE ACCOUNT")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(signupButtonBackground)
            .cornerRadius(12)
            .shadow(color: primaryAccent.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .disabled(!isFormValid || isLoading)
        .opacity((!isFormValid || isLoading) ? 0.6 : 1.0)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        password == confirmPassword && 
        acceptTerms
    }
    
    private func bottomLoginSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            loginSection
        }
    }
    
    private var loginSection: some View {
        VStack(spacing: 10) {
            Text("Already have an account?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                lightFeedback.impactOccurred()
                dismiss()
            }) {
                Text("SIGN IN")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(primaryAccent)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(primaryAccent, lineWidth: 2)
                            .background(Color.adaptiveCardBackground.opacity(0.1))
                    )
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Style Components
    
    private var backgroundView: some View {
        ZStack {
            // Base gradient background (same as login page)
            LinearGradient(
                colors: [
                    Color.waterBlue.opacity(0.1),
                    Color.waterBlue.opacity(0.15),
                    Color.lightBlue.opacity(0.2),
                    Color.darkBlue.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated floating circles for visual interest (same as login page)
            GeometryReader { geometry in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.25), Color.cyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.8)
            }
        }
        .ignoresSafeArea()
    }
    
    private var formBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: [
                        Color.adaptiveCardBackground.opacity(0.95),
                        Color.adaptiveCardBackground.opacity(0.9),
                        primaryAccent.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: primaryAccent.opacity(0.2), radius: 20, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                primaryAccent.opacity(0.3),
                                primaryAccent.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3), 
                                primaryAccent.opacity(0.2), // Blue accent in border
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var inputFieldBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.9),
                        Color.white.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                primaryAccent.opacity(0.3),
                                primaryAccent.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: primaryAccent.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var signupButtonBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                primaryAccent,          // Apple blue
                lightBlue,            // Lighter variant
                secondaryBlue         // Darker variant
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func signup() {
        impactFeedback.impactOccurred()
        isLoading = true
        lightFeedback.impactOccurred()
        
        // Validate input
        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "Please fill in all fields."
            showAlert = true
            isLoading = false
            return
        } else if password != confirmPassword {
            alertMessage = "Passwords do not match."
            showAlert = true
            isLoading = false
            return
        } else if password.count < 6 {
            alertMessage = "Password must be at least 6 characters long."
            showAlert = true
            isLoading = false
            return
        } else if !acceptTerms {
            alertMessage = "Please accept the Terms of Service and Privacy Policy."
            showAlert = true
            isLoading = false
            return
        }
        
        // Use Firebase authentication
        authService.signUp(email: email, password: password, name: name) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let message):
                    print("✅ Signup successful: \(message)")
                    // Show top notification instead of alert
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSuccessNotification = true
                    }
                    
                    // Auto-hide notification after 4 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.showSuccessNotification = false
                        }
                    }
                    
                    // Clear form fields
                    self.name = ""
                    self.email = ""
                    self.password = ""
                    self.confirmPassword = ""
                    self.acceptTerms = false
                    
                case .failure(let error):
                    self.alertMessage = "Signup failed: \(error.localizedDescription)"
                    self.signupSuccessful = false
                    self.showAlert = true
                    print("❌ Signup failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignupView()
                .environmentObject(AuthService.shared)
        }
    }
}
