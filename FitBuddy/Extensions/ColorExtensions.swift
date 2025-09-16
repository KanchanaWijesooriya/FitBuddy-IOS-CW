//
//  ColorExtensions.swift
//  FitBuddy
//
//  Dark mode compatible color system
//

import SwiftUI

extension Color {
    // MARK: - App Theme Colors (Dark Mode Compatible)
    
    /// Primary accent color - adapts to dark mode
    static let appPrimary = Color.blue
    
    /// Secondary accent color
    static let appSecondary = Color.cyan
    
    /// App-specific colors that adapt to dark mode
    static let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831)
    static let primaryPurple = Color(red: 0.588, green: 0.239, blue: 0.729)
    static let redGradient = Color(red: 0.906, green: 0.298, blue: 0.235)
    
    // MARK: - Adaptive Background Colors
    
    /// Primary background that adapts to dark mode
    static let adaptiveBackground = Color(.systemBackground)
    
    /// Secondary background that adapts to dark mode
    static let adaptiveSecondaryBackground = Color(.secondarySystemBackground)
    
    /// Tertiary background that adapts to dark mode
    static let adaptiveTertiaryBackground = Color(.tertiarySystemBackground)
    
    /// Card background that adapts to dark mode
    static let adaptiveCardBackground = Color(.secondarySystemBackground)
    
    // MARK: - Adaptive Text Colors
    
    /// Primary text color that adapts to dark mode
    static let adaptivePrimaryText = Color(.label)
    
    /// Secondary text color that adapts to dark mode
    static let adaptiveSecondaryText = Color(.secondaryLabel)
    
    /// Tertiary text color that adapts to dark mode
    static let adaptiveTertiaryText = Color(.tertiaryLabel)
    
    // MARK: - Adaptive Surface Colors
    
    /// Surface color for cards and elevated elements
    static let adaptiveSurface = Color(.systemBackground)
    
    /// Grouped background color
    static let adaptiveGroupedBackground = Color(.systemGroupedBackground)
    
    // MARK: - Form and Input Colors
    
    /// Text field background that adapts to dark mode
    static let adaptiveTextFieldBackground = Color(.systemGray6)
    
    /// Border color that adapts to dark mode
    static let adaptiveBorder = Color(.separator)
    
    /// Fill color that adapts to dark mode
    static let adaptiveFill = Color(.systemFill)
    
    // MARK: - Button Colors
    
    /// Destructive button color
    static let adaptiveDestructive = Color(.systemRed)
    
    /// Success/positive button color
    static let adaptiveSuccess = Color(.systemGreen)
    
    /// Warning button color
    static let adaptiveWarning = Color(.systemOrange)
    
    // MARK: - Blue Hydration Theme Colors
    
    /// Primary water blue - main hydration theme color
    static let waterBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    
    /// Light blue - lighter variant of water theme
    static let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    
    /// Dark blue - darker variant of water theme
    static let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    
    /// Hydration teal - complementary hydration color
    static let hydrationTeal = Color(red: 0.0, green: 0.78, blue: 0.75)
    
    /// Vibrant cyan - bright hydration accent
    static let vibrantCyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    
    /// Soft mint - gentle hydration accent
    static let softMint = Color(red: 0.0, green: 0.9, blue: 0.6)
}

// MARK: - Dark Mode Helper Extensions

extension View {
    /// Applies adaptive background that works in both light and dark mode
    func adaptiveBackground() -> some View {
        self.background(Color.adaptiveBackground)
    }
    
    /// Applies adaptive card styling
    func adaptiveCardStyle() -> some View {
        self
            .background(Color.adaptiveCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    /// Applies adaptive text field styling
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