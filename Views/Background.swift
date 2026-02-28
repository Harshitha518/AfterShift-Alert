import SwiftUI

// Colors for app
extension Color {
    static let backgroundTop = Color(red: 0.06, green: 0.09, blue: 0.18)
    static let backgroundBottom = Color(red: 0.02, green: 0.06, blue: 0.09)
    
    static let card = Color.white.opacity(0.05)
    static let stroke = Color.white.opacity(0.06)
    
    static let nightAccent = Color(red: 0.42, green: 0.55, blue: 0.75)
    static let safe = Color(red: 0.42, green: 0.65, blue: 0.55)
    static let warning = Color(red: 0.82, green: 0.45, blue: 0.45)
}


// Moving gradient background for all views
struct Background: View {
    
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.06, blue: 0.14),
                        Color(red: 0.01, green: 0.02, blue: 0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.nightAccent.opacity(0.45),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.6
                        )
                    )
                    .frame(width: geo.size.width * 0.9)
                    .offset(
                        x: animate ? geo.size.width * 0.3 : -geo.size.width * 0.3,
                        y: animate ? -geo.size.height * 0.2 : geo.size.height * 0.2
                    )
                    .blur(radius: 120)
                    .animation(
                        .easeInOut(duration: 18).repeatForever(autoreverses: true),
                        value: animate
                    )
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.safe.opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.5
                        )
                    )
                    .frame(width: geo.size.width * 0.8)
                    .offset(
                        x: animate ? -geo.size.width * 0.25 : geo.size.width * 0.25,
                        y: animate ? geo.size.height * 0.3 : -geo.size.height * 0.3
                    )
                    .blur(radius: 140)
                    .animation(
                        .easeInOut(duration: 22).repeatForever(autoreverses: true),
                        value: animate
                    )
                
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.04),
                        Color.clear,
                        Color.white.opacity(0.04)
                    ],
                    startPoint: animate ? .topLeading : .bottomTrailing,
                    endPoint: animate ? .bottomTrailing : .topLeading
                )
                .blendMode(.overlay)
                .animation(
                    .easeInOut(duration: 14).repeatForever(autoreverses: true),
                    value: animate
                )
            }
            .ignoresSafeArea()
            .onAppear { animate = true }
        }
    }
}
