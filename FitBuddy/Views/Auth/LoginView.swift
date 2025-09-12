// LoginView.swift
import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isFaceIDAvailable = false
    @State private var hasSavedCredentials = false
    @State private var isLoading = false
    @State private var isFaceIDLoading = false
    @State private var showFaceIDSetup = false
    @State private var showSuccessNotification = false
    @State private var notificationMessage = ""
    
    @EnvironmentObject var authService: AuthService
    
    // Haptic feedback
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // App theme colors - Using Apple blue colors
    private let primaryAccent = Color.blue // Apple blue
    private let stepBlue = Color.blue // Blue variant
    private let secondaryBlue = Color.blue.opacity(0.8) // Darker variant of blue
    private let lightBlue = Color.blue.opacity(0.6) // Lighter variant of blue
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Flexible top spacer to center content
                    Spacer()
                        .frame(minHeight: geometry.safeAreaInsets.top + 10)
                    
                    logoSection
                    
                    Spacer()
                        .frame(height: 20)
                    
                    loginFormSection
                    
                    Spacer()
                        .frame(height: 20)
                    
                    bottomSignUpSection(geometry: geometry)
                    
                    // Flexible bottom spacer to center content
                    Spacer()
                        .frame(minHeight: 20)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(backgroundView)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .overlay(
            VStack {
                if showSuccessNotification {
                    successNotificationView
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSuccessNotification)
                }
                Spacer()
            }
        )
        .onAppear {
            checkBiometricAvailability()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Authentication"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showFaceIDSetup) {
            Alert(
                title: Text("Enable Face ID?"),
                message: Text("Would you like to enable Face ID for quick and secure sign-in to FitBuddy?"),
                primaryButton: .default(Text("Enable"), action: {
                    // Enable Face ID with current login credentials
                    print("Enabling Face ID through profile setup")
                    authService.saveBiometricCredentials(email: email, password: password)
                    authService.setFaceIDEnabled(true)
                    
                    // Update the UI state
                    checkBiometricAvailability()
                    showNotification(message: "Face ID Authentication Enabled Successfully")
                    print("Face ID enabled and saved to profile")
                }),
                secondaryButton: .cancel(Text("Not Now"), action: {
                    authService.setFaceIDEnabled(false)
                    print("User chose not to enable Face ID")
                })
            )
        }
    }
    
    // MARK: - View Components
    
    private var logoSection: some View {
        VStack(spacing: 15) {
            // App Logo with enhanced gradient and glow effect
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                primaryAccent.opacity(0.4),
                                primaryAccent.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 65
                        )
                    )
                    .frame(width: 110, height: 110)
                
                // Main logo circle with vibrant gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.cyan.opacity(0.8),
                                primaryAccent.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: primaryAccent.opacity(0.4), radius: 12, x: 0, y: 6)
                
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            }
            
            // Enhanced Welcome to FitBuddy text with background
            VStack(spacing: 8) {
                ZStack {
                    // Background for text
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.7),
                                    primaryAccent.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 110)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("FitBuddy")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [primaryAccent, Color.cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Sign in to continue your fitness journey")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                }
                .padding(.horizontal, 30)
            }
        }
        .padding(.top, 5)
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            inputFields
            authenticationButtons
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 26)
        .background(formBackground)
        .padding(.horizontal, 24)
    }
    
    private var inputFields: some View {
        VStack(spacing: 16) {
            emailField
            passwordField
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(primaryAccent)
                    .frame(width: 20)
                
                TextField("Enter your email", text: $email)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.primary)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
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
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(primaryAccent)
                    .frame(width: 20)
                
                if showPassword {
                    TextField("Enter your password", text: $password)
                        .font(.system(.body, design: .default))
                        .foregroundColor(.primary)
                        .textContentType(.password)
                } else {
                    SecureField("Enter your password", text: $password)
                        .font(.system(.body, design: .default))
                        .foregroundColor(.primary)
                        .textContentType(.password)
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(primaryAccent.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(inputFieldBackground)
        }
    }
    
    private var authenticationButtons: some View {
        VStack(spacing: 14) {
            if hasSavedCredentials {
                faceIDSection
            }
            loginButton
            forgotPasswordButton
        }
    }
    
    private var faceIDSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                lightFeedback.impactOccurred()
                authenticateWithFaceID()
            }) {
                HStack(spacing: 12) {
                    if isFaceIDLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "faceid")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Text(isFaceIDLoading ? "AUTHENTICATING..." : "SIGN IN WITH FACE ID")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            primaryAccent,
                            lightBlue
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: primaryAccent.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .disabled(isLoading || isFaceIDLoading)
            
            divider
        }
    }
    
    private var divider: some View {
        HStack {
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
            Text("or")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 16)
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            login()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Text(isLoading ? "SIGNING IN..." : "SIGN IN")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(loginButtonBackground)
            .cornerRadius(12)
            .shadow(color: primaryAccent.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .disabled(email.isEmpty || password.isEmpty || isLoading)
        .opacity((email.isEmpty || password.isEmpty || isLoading) ? 0.6 : 1.0)
    }
    
    private var forgotPasswordButton: some View {
        Button(action: {
            lightFeedback.impactOccurred()
            // TODO: Implement forgot password
        }) {
            Text("Forgot Password?")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(primaryAccent)
                .underline()
        }
        .padding(.top, 6)
    }
    
    private func bottomSignUpSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            signUpSection
        }
    }
    
    private var signUpSection: some View {
        VStack(spacing: 10) {
            Text("Don't have an account?")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            NavigationLink(destination: SignupView()) {
                Text("CREATE ACCOUNT")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryAccent, lightBlue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: primaryAccent.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Style Components
    
    private var backgroundView: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.blue.opacity(0.15),
                    Color.blue.opacity(0.2),
                    Color.blue.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated floating circles for visual interest
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
                        Color.white.opacity(0.95),
                        Color.white.opacity(0.9),
                        primaryAccent.opacity(0.08) // More noticeable blue tint
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
    
    private var loginButtonBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                primaryAccent,          // Apple blue
                lightBlue,             // Brighter blue
                secondaryBlue          // Deeper blue
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func login() {
        isLoading = true
        lightFeedback.impactOccurred()
        
        // Validate input
        if email.isEmpty || password.isEmpty {
            alertMessage = "Please enter both email and password."
            showAlert = true
            isLoading = false
            return
        }
        
        // Use Firebase authentication
        authService.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let message):
                    print("Login successful: \(message)")
                    // Update biometric availability after successful login
                    self.checkBiometricAvailability()
                    
                    // Force show Face ID setup dialog for testing
                    print("=== Post-Login Face ID Check ===")
                    print("Biometric Available: \(self.authService.isBiometricAvailable())")
                    print("Face ID Enabled: \(self.authService.isFaceIDEnabled())")
                    
                    if self.authService.isBiometricAvailable() && !self.authService.isFaceIDEnabled() {
                        print("Showing Face ID setup dialog")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showFaceIDSetup = true
                        }
                    } else if self.authService.isFaceIDEnabled() {
                        print("Face ID already enabled")
                    } else {
                        print("Biometrics not available on device")
                    }
                    
                    // Navigation will be handled automatically by ContentView based on authentication state
                    
                case .failure(let error):
                    self.alertMessage = "Login failed: \(error.localizedDescription)"
                    self.showAlert = true
                    print("Login failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkBiometricAvailability() {
        isFaceIDAvailable = authService.isBiometricAvailable()
        hasSavedCredentials = authService.hasSavedBiometricCredentials()
        let faceIDEnabled = authService.isFaceIDEnabled()
        let firebaseEnabled = authService.getFaceIDEnabledFromFirebase()
        
        print("=== Face ID Status Check ===")
        print("Biometric Available: \(isFaceIDAvailable)")
        print("Has Saved Credentials: \(hasSavedCredentials)")
        print("Face ID Enabled (Local): \(faceIDEnabled)")
        print("Face ID Enabled (Firebase): \(firebaseEnabled)")
        print("Current User: \(authService.currentUser?.name ?? "None")")
        print("UserDefaults FaceIDEnabled: \(UserDefaults.standard.bool(forKey: "FaceIDEnabled"))")
        print("Face ID button will show: \(hasSavedCredentials)")
        print("=============================")
    }
    
    func authenticateWithFaceID() {
        isFaceIDLoading = true
        impactFeedback.impactOccurred()
        
        authService.signInWithBiometrics { result in
            DispatchQueue.main.async {
                self.isFaceIDLoading = false
                
                switch result {
                case .success(let message):
                    self.impactFeedback.impactOccurred()
                    print("Face ID login successful: \(message)")
                    // Navigation will be handled automatically by ContentView based on authentication state
                    
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    print("Face ID login failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private var successNotificationView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
            
            Text(notificationMessage)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
    
    private func showNotification(message: String) {
        notificationMessage = message
        withAnimation {
            showSuccessNotification = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSuccessNotification = false
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
                .environmentObject(AuthService.shared)
        }
    }
}
