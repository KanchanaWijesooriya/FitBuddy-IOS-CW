import SwiftUI

struct BackButton: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    let customAction: (() -> Void)?
    
    init(customAction: (() -> Void)? = nil) {
        self.customAction = customAction
    }
    
    var body: some View {
        Button(action: {
            if let customAction = customAction {
                customAction()
            } else {
                navigationCoordinator.goBack()
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                Text("Back")
                    .font(.system(size: 17, weight: .regular))
            }
            .foregroundColor(.blue)
        }
    }
}

#Preview {
    BackButton()
        .environmentObject(NavigationCoordinator())
}
