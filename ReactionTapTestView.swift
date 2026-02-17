//
//  ReactionTapTestView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/3/26.
//

import SwiftUI

struct ReactionTapTestView: View {
    let onComplete: @MainActor (Double) -> Void
    let onDismiss: () -> Void

    let totalStimuli = 5
    @State private var currentStimulus = 0
    @State private var isWaiting = true
    @State private var startTime: Date?
    @State private var reactionTimes: [Double] = []
    @State private var message = "Get ready..."
    @State private var testEnded = false
    
    var body: some View {
        VStack(spacing: 40) {
            if testEnded {
                VStack(spacing: 24) {
                    Text("Test Complete")
                        .font(.largeTitle)
                        .bold()

                    Text("This test measures reaction speed and alertness.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Done") {
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Text("Reaction Tap Test")
                    .font(.title2)
                    .bold()
                
                Text("Stimulus \(currentStimulus + 1)/\(totalStimuli)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(isWaiting ? Color.red : Color.green)
                    .frame(width: 200, height: 200)
                    .cornerRadius(20)
                    .onTapGesture {
                        handleTap()
                    }
                    .animation(.easeInOut(duration: 0.2), value: isWaiting)
            }
        }
        .padding()
        .onAppear {
            startNextStimulus()
        }
    }
    
  
    func startNextStimulus() {
        guard currentStimulus < totalStimuli else {
            testEnded = true
            
            let avg = averageReactionTime()

            // Convert reaction time → alertness score (example mapping)
            let alertnessScore = max(0, min(100, 100 - avg * 80))

            onComplete(alertnessScore)

            
            return
        }
        
        isWaiting = true
        message = "Wait for green..."
        startTime = nil
        
        // Random delay before green
        let delay = Double.random(in: 1...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            isWaiting = false
            startTime = Date()
            message = "Tap now!"
        }
    }
    
    func handleTap() {
        guard !isWaiting, let startTime = startTime else { return }
        
        // Record reaction time
        let reactionTime = Date().timeIntervalSince(startTime)
        reactionTimes.append(reactionTime)
        message = "Good!"
        
        // Move to next stimulus after short delay
        currentStimulus += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startNextStimulus()
        }
    }
    
    func averageReactionTime() -> Double {
        guard !reactionTimes.isEmpty else { return 0.0 }
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
}
