
import SwiftUI


// Final view (display of score + adjustments and advice)
struct FinalDecisionView: View {

    let alertness: AlertnessResult
    let baseScore: Double
    let finalScore: Double
    let delayMinutes: Double
    let napMinutes: Double
    let caffeineLevel: Int
    let freshAir: Bool
    let departureTime: Date
    let circadianPhase: CircadianPhase
    
    let onReduceMore: () -> Void
    let onStartOver: () -> Void

    private var scoreDelta: Double { finalScore - baseScore }

    private var scoreColor: Color {
        finalScore >= 70 ? .safe :
        finalScore >= 40 ? .yellow :
        .warning
    }

    private var riskLabel: String {
        finalScore >= 70 ? "Safe Range" :
        finalScore >= 40 ? "Moderate Risk" :
        "High Risk"
    }

    private var circadianLabel: String {
        switch circadianPhase {
        case .deepLow: return "Circadian Low"
        case .rising: return "Circadian Recovery"
        case .neutral: return "Neutral Phase"
        }
    }
    
    private var driverImageName: String {
        if finalScore >= 70 {
            return "Driver-alert"
        } else if finalScore >= 40 {
            return "Driver-moderate"
        } else {
            return "Driver-sleepy"
        }
    }
    
    var body: some View {
        ZStack {
            Background()

            ScrollView {
                VStack(spacing: 40) {

                    VStack(spacing: 12) {
                        Text("Final Drive Assessment")
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(.white)

                        Text("Your projected driving alertness / 100")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    // Score + status
                    Card {
                        ZStack {
                            HStack {
                                Image(driverImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 245, height: 350)
                                
                                VStack(spacing: 24) {
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 22)
                                        
                                        Circle()
                                            .trim(from: 0, to: finalScore / 100)
                                            .stroke(
                                                scoreColor,
                                                style: StrokeStyle(
                                                    lineWidth: 22,
                                                    lineCap: .round
                                                )
                                            )
                                            .rotationEffect(.degrees(-90))
                                            .animation(.easeInOut(duration: 0.7), value: finalScore)
                                        
                                        Text("\(Int(finalScore))")
                                            .font(.system(size: 72, weight: .black))
                                            .foregroundStyle(scoreColor)
                                    }
                                    .frame(width: 240, height: 240)
                                    
                                   
                                    Text(riskLabel.uppercased())
                                        .font(.caption.weight(.bold))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(scoreColor.opacity(0.2))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(scoreColor, lineWidth: 1)
                                        )
                                        .foregroundStyle(scoreColor)
                                }
                                .padding(40)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Adjustments made to score
                    if scoreDelta != 0 {
                        Card {
                            
                            VStack(spacing: 8) {
                                Text("Total Improvement")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.7))

                                Text(scoreDelta >= 0 ?
                                     "+\(Int(scoreDelta))" :
                                     "\(Int(scoreDelta))")
                                    .font(.system(size: 44, weight: .bold))
                                    .foregroundStyle(scoreDelta >= 0 ? Color.safe : Color.warning)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Breakdown of factors contributing to score
                    Card {
                        VStack(alignment: .leading, spacing: 20) {

                            Text("Score Breakdown")
                                .font(.title2.bold())

                            BreakdownRow(title: "Base Alertness", value: baseScore)

                            if napMinutes > 0 {
                                BreakdownRow(
                                    title: "Nap (\(Int(napMinutes)) min)",
                                    value: napMinutes <= 20 ?
                                    napMinutes / 10 * 5 : 10
                                )
                            }

                            if caffeineLevel > 0 {
                                BreakdownRow(
                                    title: "Caffeine Boost",
                                    value: Double(min(caffeineLevel * 6, 12))
                                )
                            }

                            if freshAir {
                                BreakdownRow(title: "Fresh Air", value: 4)
                            }
                        }
                    }

                    // Adjusted departure time after all adjustments
                    Card {
                        
                        VStack(spacing: 12) {

                            Text("Adjusted Departure Plan")
                                .font(.title3.bold())
                                .foregroundStyle(.white)

                            Text(departureTime.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)

                            Text(circadianLabel)
                                .foregroundStyle(
                                    circadianPhase == .deepLow ? Color.warning :
                                    circadianPhase == .rising ? Color.safe :
                                    .secondary
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // AI Explanation
                    if #available(iOS 26.0, *) {
                        AIExplanationView(
                            alertness: alertness,
                            baseScore: baseScore,
                            finalScore: finalScore,
                            delayMinutes: delayMinutes,
                            napMinutes: napMinutes,
                            caffeineLevel: caffeineLevel,
                            freshAir: freshAir,
                            departureTime: departureTime,
                            circadianPhase: circadianPhase
                        )
                    }
                    
                    // Final action options
                    Card {
                        VStack(spacing: 20) {

                            Divider()
                                .opacity(0.3)

                            Text("What would you like to do next?")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.9))

                            Text("You can try additional safety adjustments or restart the assessment with new inputs.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)

                            VStack(spacing: 14) {
                                Button(action: onReduceMore) {
                                    PrimaryButtonStyleView(title: "Make More Reductions")
                                }

                                Button(action: onStartOver) {
                                    SecondaryButtonStyleView(title: "Start Over")
                                }
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    
                }
                .padding(40)
                
                
            }
        }
    }
}

// Breakdown of factors
struct BreakdownRow: View {
    let title: String
    let value: Double

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("+\(Int(value))")
                .bold()
                .foregroundStyle(Color.safe)
        }
    }
}

