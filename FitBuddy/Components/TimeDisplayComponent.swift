// Time display component

import SwiftUI
import Foundation

struct TimeDisplayComponent: View {
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: currentTime)
        let components = time.components(separatedBy: ":")
        
        if let hours = components.first, let minutes = components.last {
            return "\(hours)h \(minutes)min"
        }
        return "00h 00min"
    }
    
    var body: some View {
        Text(timeString)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onAppear {
                currentTime = Date()
            }
    }
}

struct TimeDisplayLargeComponent: View {
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: currentTime)
        let components = time.components(separatedBy: ":")
        
        if let hours = components.first, let minutes = components.last {
            return "\(hours)hrs \(minutes)min"
        }
        return "00hrs 00min"
    }
    
    var body: some View {
        Text(timeString)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onAppear {
                currentTime = Date()
            }
    }
}

#Preview {
    VStack {
        TimeDisplayComponent()
        TimeDisplayLargeComponent()
    }
}
