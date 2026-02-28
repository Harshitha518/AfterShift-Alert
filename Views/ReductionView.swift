
import SwiftUI
import Foundation

// Circadian Phase Model
enum CircadianPhase {
    case deepLow
    case rising
    case neutral
}

// View where users make adjustments to their alertness score + view effects in real time
struct ReductionView: View {
    let alertness: AlertnessResult
    let circadianLowWindow: String
    let wakeUpTime: Date
    let shiftEndTime: Date
    
    enum GuideStep {
        case intro
        case departureTime
        case nap
        case caffeine
        case environment
        case results
    }
    
    
        var guideText: String {
            switch guideStep {
            case .intro:
                return """
                Now you can simulate actions to get a sense of what's the best way to increase short term alertness and reduce immediate driving risk after your night shift.
                Your base alertness score is \(Int(alertness.score)), calculated from your sleep, circadian rhythm, and any optional cognitive tests you completed.
                """
            case .departureTime:
                return """
                Delaying your departure can help you avoid circadian lows (3 - 6 AM), when alertness naturally dips. Delaying your departure can also reduce your alertness score if the delay pushes you into a circadian low.
                Your score will be adjusted based on how much you delay your commute.
                """
            case .nap:
                return """
                Taking short naps (10 - 20 min) restore alertness with minimal sleep inertia.
                Taking longer naps provide diminishing returns and may temporarily reduce alertness.
                """
            case .caffeine:
                return """
                Intaking caffeine provides a temporary boost to attention and reaction time.
                Each level increases your score slightly, but effects are short-lived.
                """
            case .environment:
                return """
                Fresh air and exposure to bright light can stimulate alertness.
                Movement and morning sunlight help accelerate circadian recovery.
                """
            case .results:
                return """
                You now have an adjusted alertness score after considering all interventions.
                Green indicates safe, yellow indicates moderate risk, and red indicates high risk.
                Explore combinations of options to find the interventions most optimal and convenient for you.
                """
            }
        }
    
        
        var guideTitle: String {
            switch guideStep {
            case .intro: return "What Can You Do Now?"
            case .departureTime: return "Adjust Departure Time"
            case .nap: return "Take a Nap"
            case .caffeine: return "Caffeine Intake"
            case .environment: return "Environmental Factors"
            case .results: return "Final Alertness"
            }
        }
    
    var totalSteps: Int { 6 }

    var currentStepNumber: Int {
        switch guideStep {
        case .intro: return 1
        case .departureTime: return 2
        case .nap: return 3
        case .caffeine: return 4
        case .environment: return 5
        case .results: return 6
        }
    }


    
    @State private var guideStep: GuideStep = .intro
    
    @State private var showFinalScreen = false

    @State private var delayMinutes: Double = 0
    @State private var napMinutes: Double = 0
    @State private var caffeineLevel: Int = 0
    @State private var freshAir: Bool = false
    @State private var shiftLight: Bool = false
    @State private var morningLight: Bool = false


    var effectiveDelayMinutes: Double {
        delayMinutes + napMinutes
    }

    var adjustedAlertness: Double {
        var score = alertness.score


        let departureTime = Calendar.current.date(
            byAdding: .minute,
            value: Int(effectiveDelayMinutes),
            to: shiftEndTime
        ) ?? Date()

        score += Double(delayRiskImpact(
            delayMinutes: effectiveDelayMinutes,
            departureTime: departureTime
        ))

        
        let napBenefit: Double

        if napMinutes <= 20 {
            napBenefit = napMinutes / 10 * 5
        } else {
            napBenefit = 10
        }

        score += napBenefit



  
        score += Double(min(caffeineLevel * 6, 12))

        if freshAir { score += 4 }

        return min(max(score, 0), 100)
    }

    var adjustedAlertnessLevel: String {
        switch adjustedAlertness {
        case 70...100: return "High Alertness"
        case 40..<70: return "Moderate Alertness"
        default: return "Lower Alertness"
        }
    }

    
    var departureTime: Date {
        Calendar.current.date(
            byAdding: .minute,
            value: Int(effectiveDelayMinutes),
            to: shiftEndTime
        ) ?? Date()
    }

    var departureHour: Int {
        Calendar.current.component(.hour, from: departureTime)
    }

    var circadianPhaseLabel: String {
        switch circadianPhase(at: departureTime) {
        case .deepLow: return "Circadian Low"
        case .rising: return "Circadian Recovery"
        case .neutral: return "Neutral"
        }
    }
    
    var scoreColor: Color {
        adjustedAlertness >= 70 ? .safe :
        adjustedAlertness >= 40 ? .yellow :
        .warning
    }

    var scoreInterpretation: String {
        switch adjustedAlertness {
        case 70...100:
            return "Comparable to a well-rested morning drive"
        case 40..<70:
            return "Impairment risk present — caution advised"
        default:
            return "High drowsy-driving risk"
        }
    }



    var body: some View {
        ZStack {
            Background()
            
            HStack(alignment: .bottom, spacing: 40) {

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 24) {

                        // Guide instructions to make adjustments including explanations of how each affects score
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
                                        Button(action: previousGuideStep) {
                                            SecondaryButtonStyleView(title: "Back")
                                        }
                                    }

                                    if guideStep != .results {
                                        Button(action: advanceGuide) {
                                            PrimaryButtonStyleView(title: "Continue")
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Adjustment cards
                        Card {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "steeringwheel")
                                    Text("Adjust Departure Time")
                                        .font(.headline)
                                }
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Delay Departure")
                                        Spacer()
                                        Text("\(Int(delayMinutes)) min")
                                            .font(.headline)
                                    }
                                    Slider(value: $delayMinutes, in: 0...60, step: 10)
                                        .tint(.nightAccent)
                                    
                                    HStack {
                                        Text("Take Short Nap")
                                        Spacer()
                                        Text("\(Int(napMinutes)) min")
                                            .font(.headline)
                                    }
                                    Slider(value: $napMinutes, in: 0...30, step: 10)
                                        .tint(.nightAccent)
                                    
                                }
                                .padding(.leading, 30)
                                .padding(.top)
                                
                                
                                Text("Total departure shift: \(Int(effectiveDelayMinutes)) min")
                                    .font(.headline)
                            }
                        }
                        .highlight(guideStep == .departureTime || guideStep == .nap)
                        .opacity(guideStep == .departureTime || guideStep == .nap || guideStep == .results ? 1 : 0.5)
                        .allowsHitTesting(guideStep == .departureTime || guideStep == .nap || guideStep == .results)
                        
                        
                        Card {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "cup.and.saucer.fill")
                                    Text("Caffeine Intake")
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading) {
                                    Picker("Caffeine", selection: $caffeineLevel) {
                                        Text("None").tag(0)
                                        Text("Small").tag(1)
                                        Text("Moderate").tag(2)
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.leading, 30)
                                
                            }
                        }
                        .highlight(guideStep == .caffeine)
                        .opacity(guideStep == .caffeine || guideStep == .results ? 1 : 0.5)
                        .allowsHitTesting(guideStep == .caffeine || guideStep == .results)
                        
                        Card {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "cloud.sun.fill")
                                    Text("Environmental Factors")
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading) {
                                    Toggle("Exposure To Fresh Air", isOn: $freshAir)
                                        .tint(.nightAccent)
                                    Toggle("Exposure To Bright Light During Shift", isOn: $shiftLight)
                                        .tint(.nightAccent)
                                    Toggle("Exposure To Natural Light During Commute", isOn: $morningLight)
                                        .tint(.nightAccent)
                                }
                                .padding(.leading, 30)
                                
                            }
                        }
                        .highlight(guideStep == .environment)
                        .opacity(guideStep == .environment || guideStep == .results ? 1 : 0.5)
                        .allowsHitTesting(guideStep == .environment || guideStep == .results)
                        
                    }
                    .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                    .background(Color.white.opacity(0.1))

                
                VStack(alignment: .leading, spacing: 24) {
                    // Real-time alertness score
                    Card {
                        VStack(spacing: 16) {
                            Text("Alertness Score")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("\(Int(adjustedAlertness))")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundStyle(scoreColor)
                            
                            Text(adjustedAlertnessLevel)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            
                            Text(scoreInterpretation)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Confirm adjustments
                    if guideStep == .results {
                        Spacer()
                        Button(action: {
                            showFinalScreen = true
                        }) {
                            PrimaryButtonStyleView(title: "Review Final Plan")
                        }
                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            .padding(40)
            .navigationTitle("Risk Reduction Simulator")
            .navigationDestination(isPresented: $showFinalScreen) {
                FinalDecisionView(
                    baseScore: alertness.score,
                    finalScore: adjustedAlertness,
                    delayMinutes: effectiveDelayMinutes,
                    napMinutes: napMinutes,
                    caffeineLevel: caffeineLevel,
                    freshAir: freshAir,
                    departureTime: departureTime,
                    circadianPhase: circadianPhase(at: departureTime),
                    cognitiveContribution: alertness.score - alertness.kssEquivalent,

                    onReduceMore: {
                        showFinalScreen = false
                    },

                    onStartOver: {
                        resetAllInputs()
                        showFinalScreen = false
                    }
                )
            }

        }
    }
    
    func resetAllInputs() {
        delayMinutes = 0
        napMinutes = 0
        caffeineLevel = 0
        freshAir = false
        shiftLight = false
        morningLight = false
        guideStep = .intro
    }

    func advanceGuide() {
        switch guideStep {
            case .intro: guideStep = .departureTime
            case .departureTime: guideStep = .nap
            case .nap: guideStep = .caffeine
            case .caffeine: guideStep = .environment
            case .environment: guideStep = .results
            case .results: guideStep = .results

        }
    }
    
    func previousGuideStep() {
        switch guideStep {
            case .departureTime: guideStep = .intro
            case .nap: guideStep = .departureTime
            case .caffeine: guideStep = .nap
            case .environment: guideStep = .caffeine
            case .results: guideStep = .environment
            case .intro: break
        }
    }
    
    
    func circadianPhase(at time: Date) -> CircadianPhase {
        let hour = Calendar.current.component(.hour, from: time)

        if hour >= 3 && hour < 6 {
            return .deepLow
        } else if hour >= 6 && hour < 10 {
            return .rising
        } else {
            return .neutral
        }
    }

    func delayRiskImpact(
        delayMinutes: Double,
        departureTime: Date
    ) -> Int {

        let phase = circadianPhase(at: departureTime)

        switch phase {
        case .deepLow:
            // Staying awake longer during circadian low is harmful
            return +6

        case .rising:
            // Delaying into circadian recovery helps
            return -min(Int(delayMinutes / 15) * 3, 9)

        case .neutral:
            // Small benefit only
            return -min(Int(delayMinutes / 30) * 2, 4)
        }
    }
}


