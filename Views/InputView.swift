//
//  SwiftUIView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/3/26.
//

import SwiftUI

struct AlertnessResult {
    let score: Double
    let kssEquivalent: Double
    
    var confidence: Double = 0.95
    var explanation: [String] = []

}


extension Color {
    static let backgroundTop = Color(red: 0.06, green: 0.09, blue: 0.18)
    static let backgroundBottom = Color(red: 0.02, green: 0.06, blue: 0.09)
    
    static let card = Color.white.opacity(0.05)
    static let stroke = Color.white.opacity(0.06)
    
    static let nightAccent = Color(red: 0.42, green: 0.55, blue: 0.75)
    static let safe = Color(red: 0.42, green: 0.65, blue: 0.55)
    static let warning = Color(red: 0.82, green: 0.45, blue: 0.45)
}


struct Background: View {
    
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                // 1️⃣ Base diagonal gradient (deeper contrast)
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.06, blue: 0.14),
                        Color(red: 0.01, green: 0.02, blue: 0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 2️⃣ Large moving accent glow
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
                
                // 3️⃣ Secondary green glow
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
                
                // 4️⃣ Subtle light grain / shimmer layer
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


struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            content
                .padding(24)
                .glassEffect(in: .rect(cornerRadius: 20))
            
        } else {
      
            content
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                )
        }
    }
}



struct InputView: View {
    
    enum GuideStep {
        case intro
        case shiftTimeline
        case sleepContext
        case drivingHistory
        case review
    }
    
    @State private var guideStep: GuideStep = .intro
    
    var guideText: String {
        switch guideStep {
        case .intro:
            return "Welcome! This tool estimates your alertness at the end of your shift using a biologically informed model that considers sleep pressure, your circadian rhythm, and time awake."
            
        case .shiftTimeline:
            return "First, set when you woke up and when your shift ends. These times help calculate your circadian alertness (Process C), which reflects the natural peaks and dips in attention across the day."
            
        case .sleepContext:
            return "Next, indicate how much sleep you’ve had in the last 24 hours. This influences sleep pressure (Process S), which builds the longer you’re awake and recovers during sleep."
            
        case .drivingHistory:
            return "Finally, let us know if you’ve experienced any recent drowsy driving close calls. This adds context to your alertness risk, accounting for individual sensitivity to sleep deprivation."
            
        case .review:
            return "All done! Review your inputs and tap \"Analyze Driving Risk\" to see your estimated alertness, including the combined effects of sleep, circadian rhythm, and time awake."
        }
    }
    
    var totalSteps: Int { 5 }

    var currentStepNumber: Int {
        switch guideStep {
        case .intro: return 1
        case .shiftTimeline: return 2
        case .sleepContext: return 3
        case .drivingHistory: return 4
        case .review: return 5
        }
    }

    var guideTitle: String {
        switch guideStep {
        case .intro: return "Welcome"
        case .shiftTimeline: return "Shift Timeline"
        case .sleepContext: return "Sleep Context"
        case .drivingHistory: return "Driving History"
        case .review: return "Review"
        }
    }

    
    @State private var wakeUpTime: Date = {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: yesterday)!
    }()
    
    @State private var shiftEndTime: Date = {
        Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!
    }()
    
    @State private var sleepHours = 5.0
    @State private var hadCloseCall = false
    
    var hoursAwake: Double {
        AlertnessAdapter.computeHoursAwake(
            wakeUp: wakeUpTime.timeOfDay,
            shiftEnd: shiftEndTime.timeOfDay
        )
    }


    
    var body: some View {
        NavigationStack {
                ZStack {
                    Background()
          
                    HStack(alignment: .bottom, spacing: 40) {
                        
                        VStack {
                            Card {
                                VStack(alignment: .leading, spacing: 24) {
                                    
                                    // STEP HEADER
                                    HStack(spacing: 10) {
                                        Image(systemName: "book.fill")
                                        Text("Step \(currentStepNumber) of \(totalSteps)")
                                            .font(.headline)
                                    }
                                    .foregroundStyle(.white.opacity(0.85))
                                    
                                    // PROGRESS BAR
                                    ProgressView(
                                        value: Double(currentStepNumber),
                                        total: Double(totalSteps)
                                    )
                                    .tint(.nightAccent)
                                    
                                    Divider().opacity(0.2)
                                    
                                    // GUIDE TITLE
                                    Text(guideTitle)
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                    
                                    // GUIDE BODY
                                    Text(guideText)
                                        .font(.title)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer(minLength: 20)
                                    
                                    if guideStep != .review {
                                        Button(action: advanceGuide) {
                                            Text("Continue")
                                                .font(.headline)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Capsule().fill(Color.nightAccent))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        
                        VStack(spacing: 24) {
                            // Shift Timeline
                            Card {
                                VStack(alignment: .leading, spacing: 16) {
                                    Label("Shift Timeline", systemImage: "clock.fill")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white.opacity(0.9))
                                    
                                    DatePicker(
                                        "When did you wake up?",
                                        selection: $wakeUpTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    
                                    DatePicker(
                                        "When does your shift end?",
                                        selection: $shiftEndTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                
                                                Capsule()
                                                    .fill(Color.white.opacity(0.08))
                                                    .frame(height: 8)
                                                
                                                Capsule()
                                                    .fill(Color.nightAccent)
                                                    .frame(
                                                        width: min(CGFloat(hoursAwake / 24.0) * geo.size.width,
                                                                   geo.size.width),
                                                        height: 8
                                                    )
                                            }
                                        }
                                        .frame(height: 8)
                                        
                                        HStack {
                                            Text("Total time awake at shift end")
                                                .font(.subheadline)
                                                .foregroundStyle(.white.opacity(0.6))
                                            
                                            Spacer()
                                            
                                            Text("\(hoursAwake, specifier: "%.1f") hours")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    
                                }
                                .tint(Color.nightAccent)
                                .foregroundStyle(.white.opacity(0.85))
                            }
                            .highlight(guideStep == .shiftTimeline)
                            .opacity(guideStep == .shiftTimeline || guideStep == .review ? 1 : 0.5)
                            .allowsHitTesting(guideStep == .shiftTimeline || guideStep == .review)
                            
                            
                            // Sleep Context
                            Card {
                                VStack(alignment: .leading, spacing: 16) {
                                    Label("Sleep Context", systemImage: "bed.double.fill")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white.opacity(0.9))
                                    
                                    HStack {
                                        Text("Sleep in last 24 hours")
                                            .foregroundStyle(.white.opacity(0.7))
                                        Spacer()
                                        Text("\(sleepHours, specifier: "%.1f") hour(s)")
                                            .font(.headline)
                                            .foregroundStyle(Color.safe)
                                    }
                                    
                                    Slider(value: $sleepHours, in: 0...12, step: 0.5)
                                        .tint(.nightAccent)
                                }
                            }
                            .highlight(guideStep == .sleepContext)
                            .opacity(guideStep == .sleepContext || guideStep == .review ? 1 : 0.5)
                            .allowsHitTesting(guideStep == .sleepContext || guideStep == .review)
                            
                            
                            // Driving History
                            Card {
                                VStack(alignment: .leading, spacing: 16) {
                                    Label("Driving History", systemImage: "steeringwheel")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white.opacity(0.9))
                                    
                                    Toggle(
                                        "Previous drowsy driving close call",
                                        isOn: $hadCloseCall
                                    )
                                    .tint(.nightAccent)
                                    .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .highlight(guideStep == .drivingHistory)
                            .opacity(guideStep == .drivingHistory || guideStep == .review ? 1 : 0.5)
                            .allowsHitTesting(guideStep == .drivingHistory || guideStep == .review)
                            
                            
                            Spacer()
                            
                            if guideStep == .review {
                                
                                NavigationLink(destination:
                                                TestListView(
                                                    baseAlertness: AlertnessAdapter.evaluate(
                                                        wakeUpTime: wakeUpTime.timeOfDay,
                                                        shiftEndTime: shiftEndTime.timeOfDay,
                                                        sleepHours: sleepHours,
                                                        hadCloseCall: hadCloseCall
                                                    ),
                                                    circadianLowWindow: "3–6 AM",
                                                    wakeUpTime: wakeUpTime,
                                                    shiftEndTime: shiftEndTime
                                                )
                                ) {
                                    Text("Analyze Driving Risk")
                                        .font(.headline)
                                        .frame(maxWidth: 300)
                                        .padding()
                                        .background(
                                            Capsule()
                                                .fill(Color.nightAccent)
                                        )
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(.plain)
                                .animation(.easeInOut(duration: 0.4), value: sleepHours)
                            }
                        }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(40)
                    .frame(maxHeight: .infinity)
                }
                .navigationTitle("Night Shift Alertness Assessment")
                .navigationBarTitleDisplayMode(.large)
            
        }
    }
    func advanceGuide() {
        switch guideStep {
        case .intro: guideStep = .shiftTimeline
        case .shiftTimeline: guideStep = .sleepContext
        case .sleepContext: guideStep = .drivingHistory
        case .drivingHistory: guideStep = .review
        case .review: guideStep = .review
        }
    }

}




#Preview {
    InputView()
}



struct AlertnessCurvePoint: Identifiable {
    let id = UUID()
    let hourOffset: Double   // -12 to +12
    let circadian: Double    // 0–1
    let sleepPressure: Double
    let inertia: Double
    let alertness: Double
}

struct LineGraph: View {
    let values: [Double]
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        GeometryReader { geo in
            Path { path in
                guard values.count > 1 else { return }

                let stepX = geo.size.width / CGFloat(values.count - 1)

                for i in values.indices {
                    let x = CGFloat(i) * stepX
                    let y = geo.size.height * (1 - values[i])

                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, lineWidth: lineWidth)
        }
    }
}

struct AlertnessExplanationGraph: View {
    let points: [AlertnessCurvePoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Biological Drivers of Alertness")
                .font(.caption)
                .foregroundStyle(Color.secondary)

            ZStack {
                LineGraph(
                    values: points.map { $0.circadian },
                    color: .blue.opacity(0.6),
                    lineWidth: 1
                )

                LineGraph(
                    values: points.map { 1 - $0.sleepPressure },
                    color: .red.opacity(0.6),
                    lineWidth: 1
                )

                LineGraph(
                    values: points.map { 1 - $0.inertia },
                    color: .purple.opacity(0.6),
                    lineWidth: 1
                )

                LineGraph(
                    values: points.map { $0.alertness },
                    color: .green,
                    lineWidth: 3
                )
            }
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
            )

            HStack(spacing: 12) {
                Label("Circadian", systemImage: "waveform")
                    .foregroundStyle(Color.blue)
                Label("Sleep Pressure", systemImage: "moon.fill")
                    .foregroundStyle(Color.red)
                Label("Inertia", systemImage: "zzz")
                    .foregroundStyle(Color.purple)
                Label("Overall", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Color.green)
            }
            .font(.caption2)
        }
    }
}



struct HighlightModifier: ViewModifier {
    let active: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(active ? Color.nightAccent : Color.clear, lineWidth: 3)
            )
            .shadow(color: active ? Color.nightAccent.opacity(0.6) : .clear, radius: 10)
            .animation(.easeInOut, value: active)
    }
}

extension View {
    func highlight(_ active: Bool) -> some View {
        self.modifier(HighlightModifier(active: active))
    }
}
