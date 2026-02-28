
import SwiftUI

// View to introduce main problem + the app playground
struct IntroView: View {
    
    enum Step: Int, CaseIterable {
        case risk
        case whyItMatters
        case howAppWorks
        
        var title: String {
            switch self {
            case .risk: return "Night Shift - Definition"
            case .whyItMatters: return "Why It’s Dangerous"
            case .howAppWorks: return "How AfterShift Alert Helps"
            }
        }
        
        var bodyText: String {
            switch self {
            case .risk:
                return """
                    Night shift work refers to working during the typical sleeping hours of the general population. It is common in healthcare, manufacturing, transportation, security, hospitality, and other essential industries that operate 24/7.

                    Most night shifts occur between 11 PM and 8 AM. These hours directly oppose the body’s natural circadian rhythm, the internal clock that promotes sleep at night and alertness during the day. 

                    As a result, night shift workers often experience increased sleep pressure and circadian misalignment. Even if they feel awake, their biological clock may be signaling reduced alertness.
                """
            case .whyItMatters:
                return """
                    Driving immediately after a night shift is uniquely risky.

                    Research shows that driving performance declines after working overnight. Drivers demonstrate increased physiological drowsiness, slower reaction times, and reduced attention, even when they believe they are alert.

                    Safety agencies report that drowsy driving contributes to a significant number of serious crashes. Extended wakefulness can impair performance in ways comparable to alcohol.

                    Beyond immediate safety risks, chronic circadian disruption has been linked to long-term health effects, including metabolic disorders, cardiovascular disease, and certain cancers. Night-shift work has been classified as a probable human carcinogen due to this disruption.

                    Understanding your personal level of alertness can help reduce preventable risk.
                """
            case .howAppWorks:
                return """
                    AfterShift Alert translates intracate sleep science into personalized, actionable insight for night shift workers heading home after their shift.

                    After working overnight, driving is often not optional: you still need to get home safely. In these moments, it is critical to understand your true level of alertness, not just how awake you feel.

                    Using your sleep history, circadian timing, commute context, and real-time performance, AfterShift Alert generates an alertness score representing your readiness to drive. It also allows you to explore realistic interventions, such as taking a short nap, delaying departure, or adjusting light exposure, so you can see how they may improve your immediate alertness and reduce risk.

                    The goal is not to eliminate necessary drives, but to make them safer through awareness and informed choice.
                    """
            }
        }
    }
    
    @State private var currentStep: Step = .risk
    @State private var showNextScreen = false
    
    var totalSteps: Int { Step.allCases.count }
    var currentStepNumber: Int { currentStep.rawValue + 1 }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                
                VStack {
                    Spacer()
                    
                    // Enscapsulate all content in card
                    Card {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(spacing: 10) {
                                Image(systemName: "book.fill")
                                Text("Step \(currentStepNumber) of \(totalSteps)")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white.opacity(0.85))
                            
                            ProgressView(value: Double(currentStepNumber), total: Double(totalSteps))
                                .tint(.nightAccent)
                            
                            Divider().opacity(0.2)
                            
                            VStack(alignment: .center, spacing: 30) {
    
                                Text(currentStep.title)
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                
       
                                Text(currentStep.bodyText)
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer(minLength: 20)
                            
                            HStack(spacing: 20) {
                                if currentStep.rawValue > 0 {
                                    Button(action: previousStep) {
                                        SecondaryButtonStyleView(title: "Back")
                                    }
                                }
                                
                                Button(action: nextStep) {
                                    PrimaryButtonStyleView(title: currentStep.rawValue == Step.allCases.count - 1 ? "Continue" : "Next")
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showNextScreen) {
                InputView()
            }
        }
    }
    
    func nextStep() {
        if let next = Step(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        } else {
            showNextScreen = true
        }
    }
    
    func previousStep() {
        if let prev = Step(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }
}
