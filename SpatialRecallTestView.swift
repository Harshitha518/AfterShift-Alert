//
//  SpatialRecallTestView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/4/26.
//

import SwiftUI

struct SpatialRecallTestView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onComplete: (Double) -> Void

    
    let gridSize = 3
    let sequenceLength = 5
    let flashDuration: TimeInterval = 0.8
    let totalRounds = 5

    @State private var sequence: [Int] = []
    @State private var currentFlashIndex = 0
    @State private var showingFlash = true
    @State private var userInput: [Int] = []
    
    @State private var correctSteps = 0
    @State private var testEnded = false
    @State private var reactionTimes: [Double] = []
    @State private var replicationStartTime: Date?
    
    @State private var lastTappedBlock: Int?
    @State private var currentRound = 1
    @State private var totalCorrectSteps = 0
    @State private var totalTaps = 0

    var body: some View {
        VStack(spacing: 30) {
            if testEnded {
                VStack(spacing: 20) {
                    Text("Spatial Recall Test Complete!")
                        .font(.title)
                        .bold()
                    Text("Overall Accuracy: \(String(format: "%.0f%%", overallAccuracy()))")
                    if !reactionTimes.isEmpty {
                        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
                        Text(String(format: "Average Reaction Time: %.2fs", avg))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("Round \(currentRound)/\(totalRounds) — \(showingFlash ? "Watch the sequence" : "Repeat the sequence")")
                    .font(.headline)

                if !showingFlash {
                    Text("Step \(userInput.count)/\(sequenceLength)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridSize), spacing: 20) {
                    ForEach(0..<gridSize*gridSize, id: \.self) { index in
                        Rectangle()
                            .foregroundColor(colorForBlock(index))
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .onTapGesture {
                                if !showingFlash {
                                    handleUserTap(index)
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: showingFlash)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            startNextRound()
        }
    }


    func startNextRound() {
        guard currentRound <= totalRounds else {
            finishTest()
            return
        }

        let allIndices = Array(0..<gridSize * gridSize)
        sequence = Array(allIndices.shuffled().prefix(sequenceLength))

        currentFlashIndex = 0
        showingFlash = true
        userInput = []
        correctSteps = 0
        replicationStartTime = nil
        lastTappedBlock = nil

        flashNextBlock()
    }


    func flashNextBlock() {
        guard currentFlashIndex < sequenceLength else {
            showingFlash = false
            replicationStartTime = Date() // start timing user taps
            return
        }

        showingFlash = true
        
        let blockToFlash = sequence[currentFlashIndex]

        
        DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
            currentFlashIndex += 1
            flashNextBlock()
        }
    }

    func colorForBlock(_ index: Int) -> Color {
        if showingFlash && currentFlashIndex < sequence.count && index == sequence[currentFlashIndex] {
            return .yellow
        } else if userInput.contains(index) {
            return .green
        } else if index == lastTappedBlock {
            return .orange.opacity(0.8)
        } else {
            return .gray.opacity(0.3)
        }
    }

    func handleUserTap(_ index: Int) {
        guard let start = replicationStartTime else { return }

        // Record reaction time
        let reaction = Date().timeIntervalSince(start)
        reactionTimes.append(reaction)
        replicationStartTime = Date() // reset timer for next tap

        // Track if correct
        if userInput.count < sequence.count && index == sequence[userInput.count] {
            correctSteps += 1
        }

        totalTaps += 1
        lastTappedBlock = index
        if userInput.last == index {
            // flash clearly if tapped twice in a row
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                lastTappedBlock = nil
            }
        }

        userInput.append(index)

        if userInput.count == sequenceLength {
            totalCorrectSteps += correctSteps
            if currentRound < totalRounds {
                currentRound += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    startNextRound()
                }
            } else {
                finishTest()
            }
        }
    }

    func overallAccuracy() -> Double {
        guard totalTaps > 0 else { return 0 }
        return (Double(totalCorrectSteps) / Double(totalTaps)) * 100
    }
    
    func finishTest() {
        testEnded = true

        let accuracyScore = overallAccuracy() // 0–100
        onComplete(accuracyScore)
    }

    
}
