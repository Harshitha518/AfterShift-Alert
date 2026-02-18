//
//  SwiftUIView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/3/26.
//

import SwiftUI
import Foundation


enum CircadianPhase {
    case deepLow
    case rising
    case neutral
}


struct ReductionView: View {
    let alertness: AlertnessResult
    let circadianLowWindow: String
    let wakeUpTime: Date

    @State private var delayMinutes: Double = 0
    @State private var napMinutes: Double = 0
    @State private var caffeineLevel: Int = 0
    @State private var freshAir: Bool = false
        
    var adjustedAlertnessLevel: String {
        switch adjustedAlertness {
        case 70...100: return "High Alertness"
        case 40..<70: return "Moderate Alertness"
        default: return "Lower Alertness"
        }
    }
    
    var effectiveDelayMinutes: Double {
        // Treat nap as also adding a delay
        delayMinutes + napMinutes
    }
    
    var adjustedAlertness: Double {
            var score = alertness.alertnessScore
            
            // Delay effect
            let departure = Calendar.current.date(
                byAdding: .minute,
                value: Int(effectiveDelayMinutes),
                to: Date()
            ) ?? Date()
            score += Double(delayRiskImpact(delayMinutes: delayMinutes, departureTime: departure))
            
            // Nap
            score += min(napMinutes / 10 * 5, 15)
            
            // Caffeine
            score += Double(min(caffeineLevel * 6, 12))
            
            // Fresh air
            if freshAir { score += 4 }
            
            return min(max(score, 0), 100)
        }

    var body: some View {
        NavigationStack {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 25) {

                    Text("Risk Reduction Actions")
                        .font(.title2)
                        .bold()

                    VStack(alignment: .leading) {
                        Text("Delay Departure: \(Int(effectiveDelayMinutes)) min")
                        Text("Delay explanation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: Binding(
                            get: { delayMinutes + napMinutes },
                            set: { newValue in
                                delayMinutes = max(napMinutes, newValue) - napMinutes
                            }
                        ), in: 0...60, step: 10)
                    }

                    VStack(alignment: .leading) {
                        Text("Short Nap: \(Int(napMinutes)) min")
                        Slider(value: $napMinutes, in: 0...30, step: 10)
                    }

                    VStack(alignment: .leading) {
                        Text("Caffeine Intake")
                        Picker("Caffeine", selection: $caffeineLevel) {
                            Text("None").tag(0)
                            Text("Small").tag(1)
                            Text("Moderate").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }

                    Toggle("Fresh air or light movement", isOn: $freshAir)

                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                VStack(alignment: .leading, spacing: 20) {

                    Text("Adjusted Driving Alertness")
                        .font(.title2)
                        .bold()

                    Text("\(Int(adjustedAlertness))")
                        .font(.system(size: 120))
                        .foregroundStyle(
                            adjustedAlertness >= 70 ? .green :
                                adjustedAlertness >= 40 ? .yellow :
                            .green
                        )
                        .bold()

                    Text(adjustedAlertnessLevel)
                        .font(.title)
                        .bold()


                    Text("""
                    These actions reduce sleep pressure and improve short-term alertness.
                    However, your circadian low (\(circadianLowWindow)) still limits safe driving.
                    """)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                                    }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .navigationTitle("Risk Reduction Simulator")
            .navigationBarTitleDisplayMode(.large)
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
            // Small benefit, capped
            return -min(Int(delayMinutes / 15) * 3, 9)

        case .neutral:
            return -min(Int(delayMinutes / 30) * 2, 4)

        }
    }

    
}


#Preview {
    ReductionView(
        alertness: AlertnessResult(
            alertnessScore: 62,
            confidence: 0.85,
            explanation: [
                "Circadian biology sets baseline alertness.",
                "Performance test adjusts for current attention.",
                "Statistical risk reflects real-world driving danger."
            ]
        ),
        circadianLowWindow: "4–7 AM", wakeUpTime: Date()
    )
}
