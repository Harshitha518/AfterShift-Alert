//
//  SwiftUIView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/3/26.
//

import SwiftUI

struct InputView: View {
    @State private var endTime = Date.now
    @State private var sleepDuration = 6.0
    @State private var wakeUpTime = Date.now
    @State private var commuteLength = 30.0
    @State private var alertness = 5.0
    @State private var hadCloseCall = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        DatePicker("Shift End Time:", selection: $endTime, displayedComponents: .hourAndMinute)
                        Text("Last Sleep Duration: \(sleepDuration, specifier: "%.1f") hours")
                        Slider(value: $sleepDuration, in: 0...12, step: 0.5)
                        DatePicker("Wake-Up Time:", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        Text("Commute Length: \(commuteLength, specifier: "%.0f")")
                        Slider(value: $commuteLength, in: 0...240, step: 5)
                        Text("Alertness Self-Check:")
                        Slider(value: $alertness, in: 0...10, step: 1)
                        Toggle("I've had a close call or accident related to fatigue before (Safety Context):", isOn: $hadCloseCall)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                        .frame(width: 1)
                        .background(Color.gray)
                    VStack(alignment: .leading, spacing: 15) {
                        Rectangle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(height: 150)
                            .overlay(Text("Circadian Wave"))
                        
                        Rectangle()
                            .fill(Color.red.opacity(0.2))
                            .frame(height: 30)
                            .overlay(Text("Sleep Debt Indicator"))
                        
                        Text("Tip: Short nap before driving can reduce fatigue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .navigationTitle("Shift Context Setup")
                .navigationBarTitleDisplayMode(.large)
            }
            
//            NavigationLink(destination: SnapshotView(alertnessResult: buildAlertnessContext(), circadianLowWindow: "4-7AM", wakeUpTime: wakeUpTime)) {
//                Text("Analyze Driving Risk")
//            }
            
            NavigationLink(destination: TestListView(
                baseAlertness: buildAlertnessContext(),
                circadianLowWindow: "4–7 AM",
                wakeUpTime: wakeUpTime
            )) {
                Text("Analyze Driving Risk")
            }
        }
    }
    
    func computeCircadianScore(shiftEndTime: Date) -> Double {
        // Convert shift end time to hour (0-23)
        let hour = Calendar.current.component(.hour, from: shiftEndTime)
        
        // Circadian alertness dip roughly 4-7 AM (low) and 1-3 PM (moderate)
        switch hour {
        case 4..<7:
            return 0.2  // deep low
        case 7..<9:
            return 0.4  // recovering
        case 13..<15:
            return 0.5  // afternoon dip
        default:
            return 0.8  // normal alertness
        }
    }

    
    func buildAlertnessContext() -> AlertnessResult {
        let sleepDebt = max(8.0 - sleepDuration, 0)
        
        // Compute circadian and sleep pressure (0-1 scale)
        let circadianScore = computeCircadianScore(shiftEndTime: endTime)
        let sleepPressure = min(sleepDebt / 8.0, 1.0)
        
        // Include subjective alertness self-check (0-10 scaled to 0-100)
        let performanceScore = alertness * 10
        
        // Include statistical risk proxy (0-100)
        let statisticalRisk = hadCloseCall ? 70.0 : 20.0
        
        let inputs = AlertnessInputs(
            circadianScore: circadianScore,
            sleepPressure: sleepPressure,
            performanceScore: performanceScore,
            statisticalRisk: statisticalRisk
        )
        
        return computeAlertness(inputs: inputs)
    }

    
}

#Preview {
    InputView()
}
