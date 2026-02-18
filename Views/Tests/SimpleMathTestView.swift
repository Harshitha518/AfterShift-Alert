//
//  MathTestView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/10/26.
//

import SwiftUI

struct MathQuestion {
    var problem: String
    var answer: Int
}

struct SimpleMathTestView: View {
    let onComplete: @MainActor (Double) -> Void
    let onDismiss: () -> Void
    
    let questionCount = 15
    let minNumber = 1
    let maxNumber = 20
    
    @State private var questions: [MathQuestion] = []
    @State private var currentIndex = 0
    @State private var testEnded = false
    @State private var reactionTimes: [Double] = []
    @State private var correctness: [Bool] = []
    @State private var trialStartTime: Date?
    
    @State private var userAnswer: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            if testEnded {
                VStack(spacing: 24) {
                    Text("Test Complete")
                        .font(.largeTitle)
                        .bold()

                    Text("This test measures focus, mental calculation speed, and accuracy.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)

                    Button("Done") {
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                if !questions.isEmpty {
                    let currentQ = questions[currentIndex]
                    
                    VStack(spacing: 20) {
                        Text("Question \(currentIndex + 1)/\(questions.count)")
                            .font(.headline)
                        
                        Text(currentQ.problem)
                            .font(.largeTitle)
                        
                        HStack {
                            TextField("Answer", text: $userAnswer)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                            
                            Button("Submit") {
                                recordAnswer()
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                        }
                    }
                    .onAppear {
                        trialStartTime = Date()
                    }
                }
            }
        }
        .padding()
        .onAppear {
            startTest()
        }
    }

    func generateQuestions(qCount: Int) -> [MathQuestion] {
        var generated: [MathQuestion] = []
        for _ in 0..<qCount {
            let a = Int.random(in: minNumber...maxNumber)
            let b = Int.random(in: minNumber...maxNumber)
            generated.append(MathQuestion(problem: "\(a) + \(b)", answer: a + b))
        }
        return generated
    }
    
    func startTest() {
        questions = generateQuestions(qCount: questionCount)
        currentIndex = 0
        testEnded = false
        reactionTimes = []
        correctness = []
        userAnswer = ""
        trialStartTime = Date()
    }
    
    func recordAnswer() {
        guard currentIndex < questions.count else { return }
        let currentQ = questions[currentIndex]
        
        // Reaction time
        if let start = trialStartTime {
            reactionTimes.append(Date().timeIntervalSince(start))
        } else {
            reactionTimes.append(0.0)
        }
        
        // Correctness
        let userInt = Int(userAnswer) ?? -999
        correctness.append(userInt == currentQ.answer)
        
        // Move to next question or finish
        userAnswer = ""
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            trialStartTime = Date()
        } else {
            testEnded = true
            finishTest()
        }
    }
    
    func finishTest() {
        let totalQuestions = correctness.count
        guard totalQuestions > 0 else {
            Task { @MainActor in
                onComplete(0)
            }
            return
        }
        
        // Accuracy (0–100)
        let accuracy = accuracyPercentage()
        
        // Average reaction time (seconds)
        let avgReaction = averageReactionTime()
        
        // Convert reaction time → speed score (0–100)
        let maxReaction: Double = 10 // max reasonable seconds per question
        let speedScore = max(0, min(100, 100 * (1 - avgReaction / maxReaction)))
        
        // Weighted alertness score: 70% accuracy, 30% speed
        let alertnessScore = max(0, min(100, accuracy * 0.7 + speedScore * 0.3))
        
        Task { @MainActor in
            onComplete(alertnessScore)
        }
    }

    func averageReactionTime() -> Double {
        guard !reactionTimes.isEmpty else { return 0.0 }
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
    func accuracyPercentage() -> Double {
        guard !correctness.isEmpty else { return 0.0 }
        let correctCount = correctness.filter { $0 }.count
        return (Double(correctCount) / Double(correctness.count)) * 100
    }
}
