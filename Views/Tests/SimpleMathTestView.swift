
import SwiftUI

// Components of a math question
struct MathQuestion {
    var problem: String
    var answer: Int
}

// Math test
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
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                if testEnded {
                    VStack(spacing: 60) {
                        Text("Test Complete")
                            .font(.largeTitle)
                            .bold()
                        

                        Button {
                            onDismiss()
                        } label: {
                            PrimaryButtonStyleView(title: "Done")
                        }
                        .padding(.horizontal)

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
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.nightAccent, lineWidth: 2))
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
        
        if let start = trialStartTime {
            reactionTimes.append(Date().timeIntervalSince(start))
        } else {
            reactionTimes.append(0.0)
        }
        

        let userInt = Int(userAnswer) ?? -999
        correctness.append(userInt == currentQ.answer)
        

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
        
        let accuracy = accuracyPercentage()
        

        let avgReaction = averageReactionTime()
        
        let maxReaction: Double = 10
        let speedScore = max(0, min(100, 100 * (1 - avgReaction / maxReaction)))
        
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
