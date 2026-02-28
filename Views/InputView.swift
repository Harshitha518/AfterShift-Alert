
import SwiftUI

// View for user to input information needed to calculate alerntess
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
            return """
            Let’s estimate your alertness at the end of your night shift. 
            You’ll answer a few brief questions about your recent sleep and work schedule so we can model your current level of physiological alertness. 
            Accurate inputs will produce a more reliable alertness estimate.
            """
            
        case .shiftTimeline:
            return """
            First, enter when you woke up and when your shift ends. 
            These times help estimate your circadian phase (Process C), which reflects predictable biological fluctuations in alertness across the 24 hour day. 
            Alertness typically dips during the early morning hours (around 3–6 am) and rises after sunrise.
            """
            
        case .sleepContext:
            return """
            Next, indicate how much sleep you’ve obtained in the past 24 hours. 
            This informs sleep pressure (Process S), which builds the longer you remain awake and decreases during sleep. 
            Higher sleep pressure is associated with slower reaction time, reduced vigilance, and increased driving risk.
            """
            
        case .drivingHistory:
            return """
            Finally, indicate whether you have experienced any recent drowsy-driving close calls. 
            This provides additional risk context, accounting for individual differences in vulnerability to sleep loss and attentional lapses.
            """
            
        case .review:
            return """
            Review your inputs and tap "Analyze Driving Risk" to generate your alertness score. 
            You will then have the option to complete brief cognitive tests to refine the estimate using real-time performance data.
            """
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

    enum AssessmentMode {
        case fast
        case advanced
    }
    
    @State private var mode: AssessmentMode = .fast
    
    @State private var wakeUpTime: Date = {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: yesterday)!
    }()
    
    @State private var shiftEndTime: Date = {
        Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!
    }()
    
    @State private var sleepHours = 8.0
    @State private var sleepTwoDaysAgo = 8.0
    @State private var sleepThreeDaysAgo = 8.0
    
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
                            
                            // Guide isntructions
                            Card {
                                VStack(alignment: .leading, spacing: 24) {
                                    
                         
                                    HStack(spacing: 10) {
                                        Image(systemName: "book.fill")
                                        Text("Step \(currentStepNumber) of \(totalSteps)")
                                            .font(.headline)
                                    }
                                    .foregroundStyle(.white.opacity(0.85))
                                    
                                    ProgressView(
                                        value: Double(currentStepNumber),
                                        total: Double(totalSteps)
                                    )
                                    .tint(.nightAccent)
                                    
                                    Divider().opacity(0.2)
                                    
                                    Text(guideTitle)
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                    
                                    Text(guideText)
                                        .font(.title)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer(minLength: 20)
                                    HStack {
                               
                                        if guideStep != .intro {
                                            Button(action: previousStep) {
                                                SecondaryButtonStyleView(title: "Back")
                                            }
                                        }

                        
                                        if guideStep != .review {
                                            Button(action: advanceGuide) {
                                                PrimaryButtonStyleView(title: "Continue")
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 0)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        
                        VStack(spacing: 24) {
                       
                            // Input cards
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
                            
                            
                            Card {
                                VStack(alignment: .leading, spacing: 16) {
                                    Label("Sleep Context", systemImage: "bed.double.fill")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white.opacity(0.9))
                                    
                                    Picker("Mode", selection: $mode) {
                                        Text("Quick").tag(AssessmentMode.fast)
                                        Text("3 Day Pattern").tag(AssessmentMode.advanced)
                                    }
                                    .pickerStyle(.segmented)
                                    .tint(.nightAccent)
                                    
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
                                    
                                    if mode == .advanced {
                                        
                                        Divider().opacity(0.2)
                                        
                                        HStack {
                                            Text("Sleep 2 nights ago")
                                            Spacer()
                                            Text("\(sleepTwoDaysAgo, specifier: "%.1f") hour(s)")
                                                .font(.headline)
                                                .foregroundStyle(Color.safe)                                        }
                                        Slider(value: $sleepTwoDaysAgo, in: 0...12, step: 0.5)
                                            .tint(.nightAccent)
                                        
                                        HStack {
                                            Text("Sleep 3 nights ago")
                                            Spacer()
                                            Text("\(sleepThreeDaysAgo, specifier: "%.1f") hour(s)")
                                                .font(.headline)
                                                .foregroundStyle(Color.safe)                                        }
                                        Slider(value: $sleepThreeDaysAgo, in: 0...12, step: 0.5)
                                            .tint(.nightAccent)
                                    }
                                }
                            }
                            .highlight(guideStep == .sleepContext)
                            .opacity(guideStep == .sleepContext || guideStep == .review ? 1 : 0.5)
                            .allowsHitTesting(guideStep == .sleepContext || guideStep == .review)
                            

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
                            
                            // Continue to next view
                            if guideStep == .review {
                                
                                NavigationLink(destination:
                                    TestListView(
                                        baseAlertness: AlertnessAdapter.evaluate(
                                            wakeUpTime: wakeUpTime.timeOfDay,
                                            shiftEndTime: shiftEndTime.timeOfDay,
                                            sleepHistory: sleepHistory(),
                                            hadCloseCall: hadCloseCall
                                        ),
                                        wakeUpTime: wakeUpTime,
                                        shiftEndTime: shiftEndTime
                                    )
                                ) {
                                    PrimaryButtonStyleView(title: "Analyze Driving Risk")
                                }
                                .buttonStyle(.plain)
                                .animation(.easeInOut(duration: 0.4), value: sleepHours)
                                .padding(.bottom, 20)
                            }
                            
                        }
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
    
    func previousStep() {
        switch guideStep {
        case .shiftTimeline: guideStep = .intro
        case .sleepContext: guideStep = .shiftTimeline
        case .drivingHistory: guideStep = .sleepContext
        case .review: guideStep = .drivingHistory
        case .intro: break
        }
    }
    
    private func sleepHistory() -> [Double] {
        switch mode {
        case .fast:
            return [sleepHours]
        case .advanced:
            return [sleepHours, sleepTwoDaysAgo, sleepThreeDaysAgo]
        }
    }
}


// Highlight for cards
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
