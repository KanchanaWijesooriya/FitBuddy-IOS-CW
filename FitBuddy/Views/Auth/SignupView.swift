// SignupView.swift
import SwiftUI

struct SignupView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
                .padding(.top, 40)
            Text("Create Account")
                .font(.title)
                .fontWeight(.bold)
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                Button(action: signup) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func signup() {
        // TODO: Implement Firebase signup logic
        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "Please fill in all fields."
            showAlert = true
        } else if password != confirmPassword {
            alertMessage = "Passwords do not match."
            showAlert = true
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
