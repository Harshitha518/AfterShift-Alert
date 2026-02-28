
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
            You can now simulate short term strategies to improve alertness and reduce immediate driving risk after your shift.
            Your current alertness score (\(Int(alertness.score))) reflects your sleep, circadian timing, and any cognitive tests completed.
            Adjust the options below to see how interventions affect your projected alertness.
            This simulator only helps estimates alertness changes (not meant to replace medical advice).
            """
            
        case .departureTime:
            return """
            Your departure time affects your circadian phase. Driving during the early morning circadian low (3 – 6 am) reduces alertness.
            Delaying your departure into circadian recovery hours (6 – 10 am) increases alertness, with greater benefit the longer you delay.
            Neutral hours provide smaller improvements. Your score will update in real time based on your chosen delay.
            """
            
        case .nap:
            return """
            Short naps (10 – 20 minutes) temporarily increase alertness, with benefits increasing up to about 20 minutes.
            Longer naps may reduce the immediate alertness benefit due to sleep inertia.
            """
            
        case .caffeine:
            return """
            Caffeine intake can improve attention and reaction speed.
            Higher intake levels produce larger short - term improvements.
            """
            
        case .environment:
            return """
            Environmental factors can modestly boost alertness.
            Fresh air and bright light provide small benefits, while exposure to natural morning light offers the strongest circadian boost.
            """
            
        case .results:
            return """
            Your adjusted alertness score reflects the combined effect of all interventions.
            Green indicates lower predicted risk, yellow indicates moderate risk, and red indicates elevated risk.
            Experiment with combinations to identify practical strategies that improve alertness before driving.
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

        if napMinutes == 0 {
            napBenefit = 0
        } else if napMinutes <= 20 {
            // Max = + 6
            napBenefit = napMinutes / 10 * 3
        } else {
            // Interia
            napBenefit = 6 - ((napMinutes - 20) / 10 * 4)
        }
        
        score += napBenefit



  
        score += Double(min(caffeineLevel * 4, 8))

        if freshAir {
            score += 2
        }
        if shiftLight {
            score += 2
        }
        if morningLight {
            score += 3
        }


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
                                        .foregroundStyle(.white)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Delay Departure")
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text("\(Int(delayMinutes)) min")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                    Slider(value: $delayMinutes, in: 0...60, step: 10)
                                        .tint(.nightAccent)
                                    
                                    HStack {
                                        Text("Take Short Nap")
                                        Spacer()
                                        Text("\(Int(napMinutes)) min")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                    Slider(value: $napMinutes, in: 0...30, step: 10)
                                        .tint(.nightAccent)
                                    
                                }
                                .padding(.leading, 30)
                                .padding(.top)
                                
                                
                                Text("Total departure shift: \(Int(effectiveDelayMinutes)) min")
                                    .font(.headline)
                                    .foregroundStyle(.white)
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
                                        .foregroundStyle(.white)
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
                                        .foregroundStyle(.white)
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
                            Text("Alertness Score / 100")
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
                    alertness: alertness,
                    baseScore: alertness.score,
                    finalScore: adjustedAlertness,
                    delayMinutes: effectiveDelayMinutes,
                    napMinutes: napMinutes,
                    caffeineLevel: caffeineLevel,
                    freshAir: freshAir,
                    departureTime: departureTime,
                    circadianPhase: circadianPhase(at: departureTime),

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
            // Worse if you drive during circadian low
            return -6

        case .rising:
            // Benefit for reaching circadian recovery
            return min(Int(delayMinutes / 20) * 3, 6)

        case .neutral:
            return min(Int(delayMinutes / 30) * 2, 4)
        }
    }
}


