//
//  SwiftUIView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/3/26.
//

import SwiftUI
import Foundation

// Circadian Phase Model
enum CircadianPhase {
    case deepLow
    case rising
    case neutral
}


struct ReductionView: View {
    let alertness: AlertnessResult
    let circadianLowWindow: String
    let wakeUpTime: Date
    let shiftEndTime: Date

    @State private var delayMinutes: Double = 0
    @State private var napMinutes: Double = 0
    @State private var caffeineLevel: Int = 0
    @State private var freshAir: Bool = false
    @State private var shiftLight: Bool = false
    @State private var morningLight: Bool = false

    // Derived Values

    var effectiveDelayMinutes: Double {
        delayMinutes + napMinutes
    }

    var adjustedAlertness: Double {
        var score = alertness.score

        // Shifted departure time
        let departureTime = Calendar.current.date(
            byAdding: .minute,
            value: Int(effectiveDelayMinutes),
            to: shiftEndTime
        ) ?? Date()

        // Circadian delay impact
        score += Double(delayRiskImpact(
            delayMinutes: effectiveDelayMinutes,
            departureTime: departureTime
        ))

        // Nap benefit (power naps help most; longer naps risk inertia)
        let napBenefit: Double

        if napMinutes <= 20 {
            napBenefit = napMinutes / 10 * 5   // up to +10
        } else {
            napBenefit = 10                    // capped due to sleep inertia
        }

        score += napBenefit



        // Caffeine (temporary boost)
        score += Double(min(caffeineLevel * 6, 12))

        // Fresh air / light movement
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
        adjustedAlertness >= 70 ? .green :
        adjustedAlertness >= 40 ? .yellow :
        .red
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

                // LEFT: Controls
                VStack(alignment: .leading, spacing: 24) {
                    Card {
                        Text("Immediate Safety Actions")
                            .font(.title2)
                            .bold()
                    }

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
                                
                                HStack {
                                    Text("Take Short Nap")
                                    Spacer()
                                    Text("\(Int(napMinutes)) min")
                                        .font(.headline)
                                }
                                Slider(value: $napMinutes, in: 0...30, step: 10)
                                
                            }
                            .padding(.leading, 30)
                            .padding(.top)
                            
                            
                            Text("Total departure shift: \(Int(effectiveDelayMinutes)) min")
                                .font(.headline)
                        }
                        
                        
                        
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
                        
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "cloud.sun.fill")
                                Text("Environmental Factors")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading) {
                                Toggle("Exposure To Fresh Air", isOn: $freshAir)
                                Toggle("Exposure To Bright Light During Shift", isOn: $shiftLight)
                                Toggle("Exposure To Natural Light During Commute", isOn: $morningLight)
                            }
                            .padding(.leading, 30)
                            
                        }
                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                    .background(Color.white.opacity(0.1))

                
                // RIGHT: Results
                VStack(alignment: .leading, spacing: 24) {
                    // Alertness Score
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
                    
                    // Departure & Circadian
                    Card {
                        VStack(spacing: 16) {
                            Text("Adjusted Departure Time")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text(departureTime.formatted(date: .omitted, time: .shortened))
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            
                            Text(circadianPhaseLabel)
                                .font(.caption)
                                .foregroundStyle(
                                    circadianPhase(at: departureTime) == .deepLow ? Color.warning :
                                        circadianPhase(at: departureTime) == .rising ? Color.safe :
                                            .secondary
                                )
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            .padding(40)
            .navigationTitle("Risk Reduction Simulator")
        }
    }

    // Circadian Logic
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



// How score was calculated
struct InputContextPreview: View {
    let shiftEndTime: Date
    let sleepHours: Double

    private var circadianWarning: String? {
        let hour = Calendar.current.component(.hour, from: shiftEndTime)
        if (3...6).contains(hour) {
            return "Circadian low expected (3–6 AM)"
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How your alertness will be evaluated")
                .font(.headline)
            
            FactorRow(icon: "clock.fill",
                      title: "Time Awake",
                      subtitle: "Extended wakefulness reduces alertness")
            
            FactorRow(icon: "moon.fill",
                      title: "Sleep Recovery",
                      subtitle: "\(sleepHours, default: "%.1f")h sleep affects baseline")
            
            FactorRow(icon: "waveform.path.ecg",
                      title: "Circadian Rhythm",
                      subtitle: "Biological time-of-day modulation")
            
            FactorRow(icon: "exclamationmark.triangle.fill",
                      title: "Risk History",
                      subtitle: "Previous drowsy driving increases caution")
            
            if let warning = circadianWarning {
                Label(warning, systemImage: "exclamationmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.nightAccent)
                    .padding(.top, 8)
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct FactorRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.nightAccent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).bold()
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
