// Dark mode compatible color system

import SwiftUI

extension Color {
    
    static let appPrimary = Color.blue
    static let appSecondary = Color.cyan
    
    static let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831)
    static let primaryPurple = Color(red: 0.588, green: 0.239, blue: 0.729)
    static let redGradient = Color(red: 0.906, green: 0.298, blue: 0.235)
    
    
    static let adaptiveBackground = Color(.systemBackground)
    
    static let adaptiveSecondaryBackground = Color(.secondarySystemBackground)
    
    static let adaptiveTertiaryBackground = Color(.tertiarySystemBackground)
    
    static let adaptiveCardBackground = Color(.secondarySystemBackground)
    
    
    static let adaptivePrimaryText = Color(.label)
    
    static let adaptiveSecondaryText = Color(.secondaryLabel)
    
    static let adaptiveTertiaryText = Color(.tertiaryLabel)
    
    
    static let adaptiveSurface = Color(.systemBackground)
    
    static let adaptiveGroupedBackground = Color(.systemGroupedBackground)
    
    
    static let adaptiveTextFieldBackground = Color(.systemGray6)
    
    static let adaptiveBorder = Color(.separator)
    
    static let adaptiveFill = Color(.systemFill)
    
    
    static let adaptiveDestructive = Color(.systemRed)
    
    static let adaptiveSuccess = Color(.systemGreen)
    
    static let adaptiveWarning = Color(.systemOrange)
    
    
    static let waterBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    
    static let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    
    static let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    
    static let hydrationTeal = Color(red: 0.0, green: 0.78, blue: 0.75)
    
    static let vibrantCyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    
    static let softMint = Color(red: 0.0, green: 0.9, blue: 0.6)
}


extension View {
    func adaptiveBackground() -> some View {
        self.background(Color.adaptiveBackground)
    }
    
    func adaptiveCardStyle() -> some View {
        self
            .background(Color.adaptiveCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func adaptiveTextFieldStyle() -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.adaptiveTextFieldBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.adaptiveBorder, lineWidth: 1)
            )
    }
}