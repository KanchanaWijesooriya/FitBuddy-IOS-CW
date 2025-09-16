//
//  CustomTextFields.swift
//  FitBuddy
//
//  Dark mode compatible text field components
//

import SwiftUI

struct AdaptiveTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let icon = icon {
                Label(title, systemImage: icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            } else {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .adaptiveTextFieldStyle()
        }
    }
}

struct AdaptiveButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: shadowColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .red
        case .destructive:
            return .white
        }
    }
    
    private var backgroundColor: some View {
        Group {
            switch style {
            case .primary:
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .secondary:
                Color.red.opacity(0.1)
            case .destructive:
                LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return .blue
        case .secondary:
            return .red
        case .destructive:
            return .red
        }
    }
}

// MARK: - Login Form Components

struct LoginFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var showToggle: Bool = false
    @Binding var isSecureVisible: Bool
    
    init(title: String, placeholder: String, text: Binding<String>, isSecure: Bool = false, showToggle: Bool = false, isSecureVisible: Binding<Bool> = .constant(false)) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.showToggle = showToggle
        self._isSecureVisible = isSecureVisible
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.adaptiveTextFieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                
                HStack {
                    Group {
                        if isSecure && !isSecureVisible {
                            SecureField(placeholder, text: $text)
                        } else {
                            TextField(placeholder, text: $text)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .foregroundColor(.primary)
                    
                    if showToggle {
                        Button(action: {
                            isSecureVisible.toggle()
                        }) {
                            Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 16)
                    }
                }
            }
            .frame(height: 48)
        }
    }
}