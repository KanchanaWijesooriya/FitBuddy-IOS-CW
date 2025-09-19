# FitBuddy - Your Personal Fitness Companion

<div align="center">
  <img src="https://img.shields.io/badge/iOS-16.0%2B-blue?logo=apple&logoColor=white" alt="iOS 16.0+"/>
  <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift&logoColor=white" alt="Swift 5.9"/>
  <img src="https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift&logoColor=white" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/Firebase-Backend-yellow?logo=firebase&logoColor=white" alt="Firebase"/>
  <img src="https://img.shields.io/badge/HealthKit-Integration-green?logo=apple&logoColor=white" alt="HealthKit"/>
  <img src="https://img.shields.io/badge/Version-1.0-brightgreen" alt="Version 1.0"/>
</div>

##  App Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="https://github.com/user-attachments/assets/5d76937e-9512-40b0-b8bd-7ce738ce3d67" width="250" alt="Workout Screen"/>
        <br/>
        <sub><b> Workout Tracking</b></sub>
        <br/>
        <sub>ABS & Cardio workout with real-time metrics</sub>
      </td>
      <td align="center">
        <img src="https://github.com/user-attachments/assets/43e04d53-3e5c-416f-b482-ffe20c58ae07" width="250" alt="Status Dashboard"/>
        <br/>
        <sub><b> Status Dashboard</b></sub>
        <br/>
        <sub>Comprehensive health overview with progress tracking</sub>
      </td>
      <td align="center">
        <img src="https://github.com/user-attachments/assets/6fd75b69-a3b0-4136-9a35-72f185fa9069" width="250" alt="Explore Screen"/>
        <br/>
        <sub><b> Explore & Discover</b></sub>
        <br/>
        <sub>Featured workouts and daily progress summary</sub>
      </td>
    </tr>
  </table>
</div>

<div align="center">
  <h3>🌟 <em>Beautiful, intuitive design meets powerful functionality</em></h3>
  <p><strong>Real-time tracking • Progress visualization • Motivational UI</strong></p>
</div>

##  Overview

FitBuddy is a comprehensive iOS fitness tracking application built with SwiftUI that helps users monitor their health journey through step tracking, workout management, hydration monitoring, and social challenges. The app leverages Apple's HealthKit framework and Firebase backend to provide a seamless and secure fitness experience.

##  Key Features

###  **Advanced Authentication & Security**
- **Face ID/Touch ID Integration**: Secure biometric authentication using LocalAuthentication framework
- **Firebase Authentication**: Email/password authentication with cloud synchronization
- **Secure Keychain Storage**: Biometric credentials stored safely in iOS Keychain
- **Multi-device Sync**: User preferences and settings synchronized across devices

###  **Comprehensive Health Tracking**
- **Real-time Step Counting**: Integration with HealthKit for accurate step tracking
- **Workout Management**: Start, track, and analyze various workout types
- **Hydration Monitoring**: Daily water intake tracking with customizable goals
- **Progress Analytics**: Detailed insights and weekly/monthly progress reports

###  **Smart Features**
- **Personalized Dashboard**: Dynamic status overview with health score calculation
- **Challenge System**: Social fitness challenges with friends and community
- **Adaptive UI**: Light/dark mode support with custom color schemes
- **Smart Notifications**: Motivational reminders and achievement celebrations
- **Voice Integration**: Siri shortcuts for quick app interactions

###  **Advanced iOS Integration**
- **CoreML & CreateML**: Machine learning for workout recommendations and progress predictions
- **AVKit Integration**: Video playback for workout demonstrations and tutorials
- **Speech Recognition**: Voice commands for hands-free workout tracking
- **HealthKit Sync**: Seamless integration with Apple Health ecosystem
- **Background Processing**: Continuous health monitoring without draining battery
- **Local Authentication**: Secure biometric access with Face ID/Touch ID

### 🎮 **Gamification Elements**
- **Achievement System**: Unlock badges and milestones
- **Streak Tracking**: Maintain hydration and workout streaks
- **Weekly Goals**: Set and achieve personalized fitness targets
- **Progress Visualization**: Beautiful charts and progress rings

##  Technical Stack

### **Core Technologies**
- **Language**: Swift 5.9
- **Framework**: SwiftUI
- **Minimum iOS Version**: 16.0
- **Architecture**: MVVM with Combine
- **Dependency Management**: Swift Package Manager

### **Apple Frameworks**
```swift
import SwiftUI           // Modern UI framework
import HealthKit         // Health data integration
import LocalAuthentication // Biometric authentication
import UserNotifications // Push and local notifications
import Combine          // Reactive programming
import CoreML           // Machine learning capabilities
import CreateML         // Model creation
import AVKit            // Audio/Video handling
```

### **Backend & Cloud Services**
```swift
import Firebase
import FirebaseAuth      // User authentication
import FirebaseFirestore // Real-time database
import FirebaseStorage   // File storage
import FirebaseAnalytics // App analytics
import FirebaseMessaging // Push notifications
```

##  Requirements

### **System Requirements**
- **iOS**: 16.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Device**: iPhone (iOS 16.0+)

### **Hardware Requirements**
- **Biometric Authentication**: Face ID or Touch ID capable device
- **HealthKit Support**: iPhone with motion coprocessor (M7 or later)
- **Network**: Internet connection for Firebase synchronization

### **Permissions Required**
- **HealthKit**: Read/write access to health data
- **Face ID**: Biometric authentication
- **Notifications**: Local and push notifications
- **Speech Recognition**: Voice command support
- **Microphone**: For voice interactions

##  Installation

### **Prerequisites**
1. **Xcode 15.0+** installed
2. **Apple Developer Account** (for device testing)
3. **Firebase Project** set up
4. **CocoaPods** or **Swift Package Manager**

### **Setup Instructions**

1. **Clone the Repository**
```bash
git clone https://github.com/KanchanaWijesooriya/FitBuddy-IOS-CW.git
cd FitBuddy-IOS-CW
```

2. **Firebase Configuration**
```bash
# Add your GoogleService-Info.plist to the project
# Configure Firebase console with your app bundle ID
```

3. **Open in Xcode**
```bash
open FitBuddy.xcodeproj
```

4. **Configure Signing & Capabilities**
- Set your development team
- Enable HealthKit capability
- Enable Push Notifications
- Configure App Groups (if needed)

5. **Build and Run**
```bash
# Select your target device
# Command + R to build and run
```

##  Architecture

### **Project Structure**
```
FitBuddy/
├──  App/
│   ├── FitBuddyApp.swift          # App entry point
│   └── ContentView.swift          # Root view
├──  Views/
│   ├── Auth/                      # Authentication views
│   ├── Dashboard/                 # Main dashboard
│   ├── Workout/                   # Workout tracking
│   ├── Steps/                     # Step counting
│   ├── Water/                     # Hydration tracking
│   ├── Challenge/                 # Social challenges
│   ├── Profile/                   # User profile
│   ├── Progress/                  # Analytics & reports
│   ├── Onboarding/               # First-time user experience
│   └── Components/               # Reusable UI components
├──  Services/
│   ├── AuthService.swift         # Authentication logic
│   ├── HealthKitService.swift    # Health data management
│   ├── WorkoutService.swift      # Workout tracking
│   ├── StepService.swift         # Step counting
│   ├── WaterService.swift        # Hydration tracking
│   ├── ChallengeService.swift    # Challenge management
│   ├── NotificationService.swift # Notification handling
│   └── FirebaseService.swift     # Firebase operations
├──  Models/
│   ├── User.swift                # User data model
│   ├── WorkoutLog.swift          # Workout data
│   ├── StepLog.swift             # Step data
│   ├── WaterLog.swift            # Water intake data
│   ├── Challenge.swift           # Challenge model
│   ├── Goal.swift                # Goal tracking
│   └── Report.swift              # Analytics model
├──  Extensions/
│   ├── ColorExtensions.swift     # Custom colors
│   └── ViewExtensions.swift      # UI helpers
└──  Components/
    ├── AdaptiveCard.swift        # Adaptive UI cards
    └── CustomTextFields.swift    # Custom input fields
```

### **Design Patterns**
- **MVVM**: Clear separation of concerns
- **Singleton**: Service classes for shared functionality
- **Observer**: Combine publishers for reactive updates
- **Dependency Injection**: Environment objects for state management

##  Configuration

### **Environment Variables**
Create a `Config.swift` file for environment-specific settings:

```swift
enum Environment {
    static let firebaseURL = "your-firebase-url"
    static let bundleID = "com.yourcompany.fitbuddy"
    static let appVersion = "1.0"
    static let buildNumber = "1"
}
```

### **Firebase Setup**
1. Create a Firebase project
2. Add iOS app with bundle identifier
3. Download `GoogleService-Info.plist`
4. Enable Authentication, Firestore, and Storage

### **HealthKit Configuration**
Add to `Info.plist`:
```xml
<key>NSHealthShareUsageDescription</key>
<string>FitBuddy needs access to read your health data including steps, distance, and workout information to track your fitness progress and provide personalized insights.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>FitBuddy needs permission to save your workout sessions, step counts, and fitness activities to your Health app to keep your health data synchronized across all your apps.</string>
```

##  Features Deep Dive

### **Authentication System**
```swift
// Biometric Authentication
func authenticateWithFaceID() {
    authService.signInWithBiometrics { result in
        switch result {
        case .success(let message):
            // Handle successful authentication
        case .failure(let error):
            // Handle authentication error
        }
    }
}
```

### **HealthKit Integration**
```swift
// Request HealthKit permissions
healthKitService.requestAuthorization { success in
    if success {
        // Start tracking health data
        healthKitService.startObservingSteps()
    }
}
```

### **CoreML & Machine Learning**
```swift
// Workout recommendation using CoreML
func getWorkoutRecommendation() {
    let model = try! WorkoutRecommendationModel(configuration: MLModelConfiguration())
    let prediction = try! model.prediction(userFitnessLevel: userLevel, 
                                         previousWorkouts: workoutHistory)
    // Display personalized workout suggestions
}
```

### **AVKit Video Integration**
```swift
// Video workout player
import AVKit

struct WorkoutVideoPlayer: UIViewControllerRepresentable {
    let videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: videoURL)
        return controller
    }
}
```

### **Speech Recognition**
```swift
// Voice command processing
func startVoiceCommand() {
    speechRecognizer.requestAuthorization { status in
        if status == .authorized {
            // Start listening for workout commands
            startWorkoutVoiceRecognition()
        }
    }
}
```

### **Real-time Data Sync**
```swift
// Observe step count changes
healthKitService.stepsPublisher
    .sink { stepCount in
        // Update UI with new step count
    }
    .store(in: &cancellables)
```

##  Testing

### **Unit Tests**
```bash
# Run unit tests
xcodebuild test -scheme FitBuddy -destination 'platform=iOS Simulator,name=iPhone 16'
```

### **UI Tests**
```bash
# Run UI tests
xcodebuild test -scheme FitBuddyUITests -destination 'platform=iOS Simulator,name=iPhone 16'
```

### **Test Coverage**
- **Authentication**: Biometric and Firebase auth flows
- **HealthKit**: Data reading and writing
- **Services**: Core business logic
- **UI Components**: View rendering and interactions

##  Deployment

### **App Store Preparation**
1. **Archive the App**
```bash
xcodebuild archive -scheme FitBuddy -destination generic/platform=iOS
```

2. **Export for App Store**
```bash
xcodebuild -exportArchive -archivePath FitBuddy.xcarchive -exportPath ./Export -exportOptionsPlist ExportOptions.plist
```

3. **Upload with Xcode**
- Use Xcode Organizer
- Validate and upload to App Store Connect

### **Build Configurations**
- **Debug**: Development with verbose logging
- **Release**: Production with optimizations
- **TestFlight**: Beta testing configuration

##  Analytics & Monitoring

### **Firebase Analytics**
- User engagement tracking
- Feature usage analytics
- Crash reporting with Crashlytics
- Performance monitoring

### **HealthKit Privacy**
- Data minimization principles
- User consent for all health data access
- Transparent data usage disclosure

##  Version History

| Version | Date | Features |
|---------|------|----------|
| **1.0** | 2025-09-19 | Initial release with core features |
| | | • Biometric authentication |
| | | • HealthKit integration |
| | | • Workout tracking |
| | | • Social challenges |
| | | • Progress analytics |

##  Roadmap

### **Upcoming Features**
- [ ] **Apple Watch App**: Native watchOS companion with real-time health monitoring
- [ ] **Siri Shortcuts**: Enhanced voice integration with custom workout commands
- [ ] **Widget Extensions**: iOS home screen widgets with live activity tracking
- [ ] **Social Features**: Enhanced community features with video sharing
- [ ] **Advanced AI Coaching**: ML-powered personalized workout and nutrition recommendations
- [ ] **Nutrition Tracking**: Meal recognition using Vision framework and calorie tracking
- [ ] **Sleep Monitoring**: Sleep quality analysis with HealthKit integration
- [ ] **AR Workouts**: ARKit-powered form correction and virtual personal trainer

### **Technical Improvements**
- [ ] **Enhanced CoreML Models**: More sophisticated fitness prediction algorithms
- [ ] **Core Data**: Local data persistence with CloudKit sync
- [ ] **Advanced Video Processing**: Real-time workout form analysis using Vision
- [ ] **Background Audio**: AVAudioSession for workout music and coaching
- [ ] **CarPlay Integration**: Hands-free workout tracking while driving
- [ ] **Shortcuts App Integration**: Custom workflow automation

##  Contributing

### **Development Guidelines**
1. **Fork** the repository
2. **Create** a feature branch
3. **Follow** Swift style guide
4. **Add** unit tests for new features
5. **Submit** a pull request

### **Code Style**
- Follow Swift API Design Guidelines
- Use SwiftLint for consistent formatting
- Comment complex business logic
- Write descriptive commit messages

## Support

### **Contact Information**
- **Developer**: Chanuka Wijesooriya
- **GitHub**: [@KanchanaWijesooriya](https://github.com/KanchanaWijesooriya)

### **Getting Help**
-  **Documentation**: Check the wiki for detailed guides
-  **Bug Reports**: Create an issue on GitHub
-  **Feature Requests**: Submit enhancement proposals
-  **Community**: Join our Discord server

##  Acknowledgments

- **Apple**: For HealthKit and SwiftUI frameworks
- **Firebase**: For backend services and authentication
- **Community**: Open source contributors and beta testers
- **Designers**: UI/UX inspiration from fitness community

---

<div align="center">
  <h3>Built with ❤️ for the fitness community</h3>
  <p>© 2025 FitBuddy. All rights reserved.</p>
</div>