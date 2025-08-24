// LoginView.swift
import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isFaceIDAvailable = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
                .padding(.top, 40)
            Text("Welcome Back!")
                .font(.title)
                .fontWeight(.bold)
            Form {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                SecureField("Password", text: $password)
                    .textContentType(.password)
                
                // Face ID Button - Positioned BEFORE regular login
                // Temporarily always show for testing (change back to just isFaceIDAvailable later)
                if true {
                    Button(action: authenticateWithFaceID) {
                        HStack {
                            Image(systemName: "faceid")
                                .font(.title2)
                            Text("Login with Face ID")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    
                    Text("or")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                
                Button(action: login) {
                    Text("Login with Password")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            Spacer()
            NavigationLink("Don’t have an account? Sign up", destination: SignupView())
                .padding(.bottom, 24)
        }
        .onAppear(perform: checkFaceID)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func login() {
        // TODO: Implement Firebase login logic
        if email.isEmpty || password.isEmpty {
            alertMessage = "Please enter both email and password."
            showAlert = true
        }
    }
    
    func checkFaceID() {
        let context = LAContext()
        var error: NSError?
        isFaceIDAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithFaceID() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login with Face ID") { success, error in
            DispatchQueue.main.async {
                if success {
                    // TODO: Handle successful Face ID login
                } else {
                    alertMessage = error?.localizedDescription ?? "Face ID failed."
                    showAlert = true
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
