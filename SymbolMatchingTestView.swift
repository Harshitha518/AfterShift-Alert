//
//  SwiftUIView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/4/26.
//

import SwiftUI

struct SymbolMatchingTestView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onComplete: (Double) -> Void


    
    let symbols = ["circle.fill", "triangle.fill", "square.fill"]
    let testDuration: TimeInterval = 15
    
    @State private var symbolNumberMap: [String: Int] = [:]
    @State private var currentSymbol = ""
    
    @State private var correctCount = 0
    @State private var timer: Timer? = nil
    @State private var timeLeft: Double = 15
    @State private var testEnded = false
    
    @State private var symbolShownTime = Date()
    @State private var reactionTimes: [Double] = []
    
    // Feedback
    @State private var selectedChoice: Int? = nil
    @State private var lastCorrect: Bool? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            if testEnded {
                VStack(spacing: 20) {
                    Text("Test Complete!")
                        .font(.title)
                        .bold()
                    Text("You matched \(correctCount) symbols correctly.")
                        .font(.title2)
                    
                    if !reactionTimes.isEmpty {
                        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
                        Text(String(format: "Average Reaction Time: %.2fs", avg))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                }
            } else {
                Text("Time Left: \(Int(timeLeft))s")
                    .font(.title2)
                
                VStack(spacing: 10) {
                    Text("Key:")
                        .bold()
                    HStack(spacing: 20) {
                        ForEach(symbols, id: \.self) { symbol in
                            VStack {
                                if let number = symbolNumberMap[symbol] {
                                    Text("\(number) = \(getShapeName(for: symbol))")
                                        .font(.caption)
                                        .bold()
                                }
                            }
                        }
                    }
                }

                Text("Match this symbol:")
                    .font(.headline)
                Image(systemName: currentSymbol)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding()
                
                HStack(spacing: 20) {
                    ForEach(symbols, id: \.self) { symbol in
                        if let number = symbolNumberMap[symbol] {
                            Button("\(number)") {
                                handleAnswer(choice: number)
                            }
                            .font(.title2)
                            .bold()
                            .frame(width: 60, height: 60)
                            .background(buttonColor(for: number))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .scaleEffect(selectedChoice == number ? 0.9 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedChoice)
                        }
                    }
                }
            }
        }
        .onAppear {
            startTest()
        }
        .padding()
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // Get shape name
    func getShapeName(for symbol: String) -> String {
        switch symbol {
        case "circle.fill":
            return "Circle"
        case "triangle.fill":
            return "Triangle"
        case "square.fill":
            return "Square"
        default:
            return ""
        }
    }
    
    // Feedback color
    func buttonColor(for number: Int) -> Color {
        if let selected = selectedChoice, selected == number {
            if let correct = lastCorrect {
                return correct ? .green : .red
            }
        }
        return Color.blue
    }
    
    // Test logic
    func startTest() {
        // Reset
        correctCount = 0
        timeLeft = testDuration
        testEnded = false
        reactionTimes = []
        selectedChoice = nil
        lastCorrect = nil
        
        // Assign unique numbers to symbols
        var assignedNumbers = Set<Int>()
        for symbol in symbols {
            var num: Int
            repeat {
                num = Int.random(in: 1...9)
            } while assignedNumbers.contains(num)
            assignedNumbers.insert(num)
            symbolNumberMap[symbol] = num
        }
        
        // Start first symbol
        nextSymbol()
        
        // Start timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timer?.invalidate()
                endTest()
            }
        }
    }
    
    func nextSymbol() {
        currentSymbol = symbols.randomElement()!
        symbolShownTime = Date()
    }
    
    func handleAnswer(choice: Int) {
        guard !testEnded else { return }

        
        // Track reaction time
        let reaction = Date().timeIntervalSince(symbolShownTime)
        reactionTimes.append(reaction)
        
        // Check correctness
        if let correctNumber = symbolNumberMap[currentSymbol] {
            lastCorrect = choice == correctNumber
            if lastCorrect! {
                correctCount += 1
            }
        }
        selectedChoice = choice
        
        // Move to next symbol after brief delay for feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard !testEnded else { return }
            nextSymbol()
            selectedChoice = nil
            lastCorrect = nil
        }
    }
    
    func endTest() {
        testEnded = true

        guard !reactionTimes.isEmpty else {
            onComplete(0)
            return
        }

        let avgReaction = reactionTimes.reduce(0, +) / Double(reactionTimes.count)

        // Example scoring:
        // Faster reactions → higher alertness
        // 0.3s ≈ very alert, 1.5s+ ≈ fatigued
        let alertnessScore = max(
            0,
            min(100, 100 - avgReaction * 60)
        )

        onComplete(alertnessScore)
    }

    
}
