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
    @State private var reactionTimes: [Double] = []  // Store in SECONDS
    @State private var message = "Get ready..."
    @State private var testEnded = false
    
    var body: some View {
        ZStack {
            Color.card
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                if testEnded {
                    VStack(spacing: 24) {
                        Text("Test Complete")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("This test measures reaction speed and alertness.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                        
                        if !reactionTimes.isEmpty {
                            VStack(spacing: 8) {
                                Text("Average: \(String(format: "%.0f", averageReactionTime() * 1000))ms")
                                    .font(.headline)
                                
                                Text("Individual times:")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                
                                ForEach(Array(reactionTimes.enumerated()), id: \.offset) { index, time in
                                    Text("\(index + 1): \(String(format: "%.0f", time * 1000))ms")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
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
                        .foregroundStyle(Color.secondary)
                    
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(Color.secondary)
                    
                    Rectangle()
                        .fill(isWaiting ? Color.red : Color.green)
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                        .onTapGesture {
                            handleTap()
                        }
                }
            }
            .padding()
            .onAppear {
                startNextStimulus()
            }
        }
    }
    
    func startNextStimulus() {
        guard currentStimulus < totalStimuli else {
            testEnded = true
            
            let avgSec = averageReactionTime()  // in seconds
            
            // Score based on reaction time
            // Excellent: < 250ms (0.25s) = 100%
            // Good: 250-400ms = 70-100%
            // Fair: 400-600ms = 40-70%
            // Poor: > 600ms (0.6s) = 0-40%
            
            let reactionScore: Double
            if avgSec < 0.25 {
                reactionScore = 100
            } else if avgSec < 0.4 {
                // Linear scale from 70 to 100
                reactionScore = 100 - ((avgSec - 0.25) / 0.15) * 30
            } else if avgSec < 0.6 {
                // Linear scale from 40 to 70
                reactionScore = 70 - ((avgSec - 0.4) / 0.2) * 30
            } else {
                // Linear scale from 0 to 40
                reactionScore = max(0, 40 - ((avgSec - 0.6) / 0.4) * 40)
            }
            
            print("📊 Average reaction: \(String(format: "%.0f", avgSec * 1000))ms")
            print("📊 Reaction score: \(String(format: "%.0f", reactionScore))/100")
            
            Task { @MainActor in
                onComplete(reactionScore)
            }
            
            return
        }
        
        isWaiting = true
        message = "Wait for green..."
        startTime = nil
        
        // Random delay before green
        let delay = Double.random(in: 1...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            isWaiting = false
            message = "Tap now!"
            
            DispatchQueue.main.async {
                startTime = Date()
            }
        }
    }

    func handleTap() {
        guard !isWaiting, let startTime = startTime else { return }
        
        // Record reaction time in SECONDS
        let reactionTime = Date().timeIntervalSince(startTime)
        print("⏱️ Reaction \(currentStimulus + 1): \(String(format: "%.0f", reactionTime * 1000))ms")
        reactionTimes.append(reactionTime)
        message = "Good! \(String(format: "%.0f", reactionTime * 1000))ms"
        
        // Move to next stimulus after short delay
        currentStimulus += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startNextStimulus()
        }
    }
    
    func averageReactionTime() -> Double {
        guard !reactionTimes.isEmpty else { return 0.0 }
        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        return avg  // Returns in seconds
    }
}
