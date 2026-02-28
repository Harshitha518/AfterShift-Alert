import SwiftUI


// Designed for iPad Pro 13-inch (M5) simulator in landscape view
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            TitleView()
                .preferredColorScheme(.dark)
        }
    }
}
