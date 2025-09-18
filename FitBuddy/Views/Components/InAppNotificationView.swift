//
//  InAppNotificationView.swift
//  FitBuddy
//
//  In-app notification overlay component
//

import SwiftUI

struct InAppNotificationView: View {
    let notification: InAppNotification
    @Binding var isVisible: Bool
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: notification.type.iconName)
                .foregroundStyle(notification.type.color)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(notification.message)
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
                    .font(.system(.caption, weight: .semibold))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(
                    color: notification.type.color.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(notification.type.color.opacity(0.2), lineWidth: 1)
                }
        }
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .offset(y: dragOffset)
        .offset(y: isVisible ? 0 : -100)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation
                    if translation.height < 0 {
                        dragOffset = translation.height
                        isDragging = true
                    }
                }
                .onEnded { value in
                    let translation = value.translation
                    if translation.height < -50 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                    isDragging = false
                }
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
    }
}

// MARK: - Notification Overlay

struct NotificationOverlay: View {
    @EnvironmentObject var notificationService: NotificationService
    
    var body: some View {
        ZStack {
            if notificationService.showInAppNotification,
               let notification = notificationService.currentNotification {
                VStack {
                    InAppNotificationView(
                        notification: notification,
                        isVisible: $notificationService.showInAppNotification,
                        onDismiss: {
                            notificationService.hideInAppNotification()
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .zIndex(1000)
            }
        }
        .allowsHitTesting(notificationService.showInAppNotification)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        
        InAppNotificationView(
            notification: InAppNotification(
                type: .achievement,
                title: "Goal Achieved!",
                message: "You've reached your daily step goal of 10,000 steps. Keep up the great work!",
                duration: 3.0
            ),
            isVisible: .constant(true),
            onDismiss: {}
        )
        .padding()
        
        Spacer()
    } 
    .background(Color.black)
}
