//
//  AdaptiveCard.swift
//  FitBuddy
//
//  Dark mode compatible card component
//

import SwiftUI

struct AdaptiveCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8
    var backgroundColor: Color = .adaptiveCardBackground
    
    init(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8, backgroundColor: Color = .adaptiveCardBackground, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: Color.primary.opacity(0.1), radius: shadowRadius, x: 0, y: 4)
            )
    }
}

// MARK: - Metric Cards for Progress Views

struct AdaptiveMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var showProgress: Bool = false
    var progress: Double = 0.0
    
    var body: some View {
        AdaptiveCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    if showProgress {
                        CircularProgressView(progress: progress, color: color)
                            .frame(width: 24, height: 24)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if showProgress {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                        .scaleEffect(y: 1.5)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Action Button Component

struct AdaptiveActionButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case outline
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundView)
            .cornerRadius(16)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .blue
        case .destructive:
            return .white
        case .outline:
            return .blue
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [.blue, .blue.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .secondary:
            Color.blue.opacity(0.1)
        case .destructive:
            LinearGradient(
                colors: [.red, .red.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .outline:
            Color.clear
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, lineWidth: 2)
                )
        }
    }
}

// MARK: - List Row Component

struct AdaptiveListRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String? = nil, iconColor: Color = .blue, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}