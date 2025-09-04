// SignupView.swift
import SwiftUI

struct SignupView: View {
    @Environment(\.presentationMode) var presentationMode
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
    
    // App theme colors - Using your app's original green
    private let primaryAccent = Color(red: 0.7, green: 1.0, blue: 0.3) // Your app's original signature green
    private let stepBlue = Color(red: 0.2, green: 0.6, blue: 0.9) // Original blue from your app
    private let secondaryGreen = Color(red: 0.6, green: 0.9, blue: 0.2) // Darker variant of your green
    private let lightGreen = Color(red: 0.8, green: 1.0, blue: 0.4) // Lighter variant of your green
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Top spacing for status bar
                        Spacer()
                            .frame(height: geometry.safeAreaInsets.top + 20)
                        
                        logoSection
                        
                        Spacer()
                            .frame(height: 40)
                        
                        signupFormSection
                        
                        Spacer()
                            .frame(height: 30)
                        
                        bottomLoginSection(geometry: geometry)
                    }
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
        VStack(spacing: 20) {
            // App Logo with your original green gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                primaryAccent,      // Your original bright green
                                lightGreen,         // Lighter variant  
                                secondaryGreen      // Darker variant
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: primaryAccent.opacity(0.5), radius: 25, x: 0, y: 12)
                
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.black.opacity(0.8))
            }
            
            // Welcome text
            VStack(spacing: 8) {
                Text("Join FitBuddy")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Create your account to start your fitness journey")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var signupFormSection: some View {
        VStack(spacing: 24) {
            inputFields
            termsSection
            signupButton
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
        .background(formBackground)
        .padding(.horizontal, 24)
    }
    
    private var inputFields: some View {
        VStack(spacing: 20) {
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
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                TextField("Enter your full name", text: $name)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.white)
                    .textContentType(.name)
                    .placeholder(when: name.isEmpty) {
                        Text("Enter your full name")
                            .foregroundColor(.white.opacity(0.5))
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
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                TextField("Enter your email", text: $email)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .placeholder(when: email.isEmpty) {
                        Text("Enter your email")
                            .foregroundColor(.white.opacity(0.5))
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
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                SecureField("Create a password", text: $password)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.white)
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
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                SecureField("Confirm your password", text: $confirmPassword)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.white)
                    .textContentType(.newPassword)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(inputFieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
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
                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
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
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
    
    private var signupButton: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            signup()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                Text(isLoading ? "CREATING ACCOUNT..." : "CREATE ACCOUNT")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
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
            Spacer()
                .frame(height: 30)
            
            loginSection
            
            Spacer()
                .frame(height: geometry.safeAreaInsets.bottom + 20)
        }
    }
    
    private var loginSection: some View {
        VStack(spacing: 12) {
            Text("Already have an account?")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                lightFeedback.impactOccurred()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("SIGN IN")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(primaryAccent)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(primaryAccent, lineWidth: 2)
                            .background(Color.black.opacity(0.2))
                    )
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Style Components
    
    private var backgroundView: some View {
        ZStack {
            // Background image with fitness theme matching your app
            Image("bgimage-workout")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            
            // Dark gradient overlay for modern signup aesthetic and text readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),  // Darker at top for status bar clarity
                    Color.black.opacity(0.3),  // Lighter in middle for content visibility
                    Color.black.opacity(0.6),  // Medium at bottom for contrast
                    Color.black.opacity(0.8)   // Darker at very bottom for login section
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    
    private var formBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.25),
                        Color.black.opacity(0.15),
                        primaryAccent.opacity(0.05) // Subtle green tint
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3), 
                                primaryAccent.opacity(0.2), // Green accent in border
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
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var signupButtonBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                primaryAccent,          // Your original bright green (0.7, 1.0, 0.3)
                lightGreen,            // Lighter variant
                secondaryGreen         // Darker variant
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func signup() {
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
                            showSuccessNotification = false
                        }
                    }
                    
                    // Clear form fields
                    name = ""
                    email = ""
                    password = ""
                    confirmPassword = ""
                    acceptTerms = false
                    
                case .failure(let error):
                    alertMessage = "Signup failed: \(error.localizedDescription)"
                    signupSuccessful = false
                    showAlert = true
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
