//
//  BackButton.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-09-04.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                Text("Back")
                    .font(.system(size: 17, weight: .regular))
            }
            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
        }
    }
}

#Preview {
    BackButton(action: {})
}
