//
//  NumberSequenceRecallTestView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/4/26.
//

import SwiftUI

struct NumberSequenceRecallTestView: View {
    let sequenceCount = 3
    let sequenceLength = 5
    let displayDuration: TimeInterval = 0.8 // seconds per digit
    
    @State private var sequences: [[Int]] = []
    @State private var currentSequenceIndex = 0
    @State private var currentDigitIndex = 0
    @State private var showingDigit = true
    @State private var userInput: [Int] = []
    
    @State private var correctDigitsTotal = 0
    @State private var correctSequencesTotal = 0
    
    @State private var testEnded = false
    
    var body: some View {
        VStack(spacing: 30) {
            if testEnded {
                VStack(spacing: 20) {
                    Text("Test Complete!")
                        .font(.title)
                        .bold()
                    
                    Text("Digits correct: \(correctDigitsTotal)/\(sequenceCount * sequenceLength)")
                    Text("Sequences fully correct: \(correctSequencesTotal)/\(sequenceCount)")
                    
                    Button("Restart Test") {
                        startTest()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if sequences.indices.contains(currentSequenceIndex) {
                Text("Sequence \(currentSequenceIndex + 1) of \(sequenceCount)")
                    .font(.headline)
                
                if showingDigit, sequences[currentSequenceIndex].indices.contains(currentDigitIndex) {
                    Text("\(sequences[currentSequenceIndex][currentDigitIndex])")
                        .font(.system(size: 80))
                        .bold()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                                advanceDigit()
                            }
                        }
                } else {
                    // User input view
                    VStack(spacing: 15) {
                        Text("Enter the sequence:")
                            .font(.headline)
                        HStack {
                            ForEach(userInput, id: \.self) { num in
                                Text("\(num)")
                                    .font(.title)
                                    .frame(width: 40)
                            }
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                            ForEach(1...9, id: \.self) { num in
                                Button("\(num)") {
                                    handleUserInput(num)
                                }
                                .frame(width: 60, height: 60)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        
                        Button("Delete") {
                            if !userInput.isEmpty { userInput.removeLast() }
                        }
                        .foregroundColor(.red)
                        .padding(.top)
                    }
                }
            } else {
                // Sequences not yet initialized
                Text("Loading sequences...")
            }
        }
        .padding()
        .onAppear {
            startTest()
        }
    }
    
    func startTest() {
        // Generate sequences
        sequences = (0..<sequenceCount).map { _ in
            (0..<sequenceLength).map { _ in Int.random(in: 1...9) }
        }
        
        currentSequenceIndex = 0
        currentDigitIndex = 0
        showingDigit = true
        userInput = []
        correctDigitsTotal = 0
        correctSequencesTotal = 0
        testEnded = false
    }
    
    func advanceDigit() {
        guard sequences.indices.contains(currentSequenceIndex) else { return }
        
        if currentDigitIndex < sequenceLength - 1 {
            currentDigitIndex += 1
        } else {
            // Sequence displayed, switch to input
            showingDigit = false
            userInput = []
        }
    }
    
    func handleUserInput(_ num: Int) {
        guard sequences.indices.contains(currentSequenceIndex) else { return }
        
        userInput.append(num)
        
        if userInput.count == sequenceLength {
            let correctSequence = sequences[currentSequenceIndex]
            let digitsCorrect = zip(userInput, correctSequence).filter { $0 == $1 }.count
            correctDigitsTotal += digitsCorrect
            if digitsCorrect == sequenceLength { correctSequencesTotal += 1 }
            
            // Move to next sequence or finish
            if currentSequenceIndex < sequenceCount - 1 {
                currentSequenceIndex += 1
                currentDigitIndex = 0
                showingDigit = true
            } else {
                testEnded = true
            }
        }
    }
}

#Preview {
    NumberSequenceRecallTestView()
}
