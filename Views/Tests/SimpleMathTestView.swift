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
    @Environment(\.dismiss) private var dismiss
    
    let onComplete: (Double) -> Void
    
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
                VStack(spacing: 20) {
                    Text("Math Test Complete!")
                        .font(.largeTitle)
                    
                    Text("Average Reaction Time: \(averageReactionTime(), specifier: "%.2f") s")
                    Text("Accuracy: \(accuracyPercentage(), specifier: "%.0f")%")
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
            
            let problem = "\(a) + \(b)"
            let answer = a + b
            
            generated.append(MathQuestion(problem: problem, answer: answer))
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
            let reactionTime = Date().timeIntervalSince(start)
            reactionTimes.append(reactionTime)
        } else {
            reactionTimes.append(0.0)
        }
        
        // Correctness
        let userInt = Int(userAnswer) ?? -999 // invalid input treated as wrong
        let correct = (userInt == currentQ.answer)
        correctness.append(correct)
        
        // Move to next question
        userAnswer = ""
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            trialStartTime = Date()
        } else {
            testEnded = true
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
