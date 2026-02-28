
import SwiftUI

// Components of a question
struct Question {
    var word: String
    var color: Color
    var isCongruent: Bool
}

// Stroop test
struct StroopTestView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onComplete: (Double) -> Void
    let onDismiss: () -> Void

    
    let words = ["Red", "Blue","Green", "Yellow", "Orange", "Purple"]
    let colors = [Color.red, Color.blue, Color.green, Color.yellow, Color.orange, Color.purple]
    let questionCount = 25
    
    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var testEnded = false
    @State private var reactionTimes: [Double] = []
    
    @State private var correctness: [Bool] = []
    @State private var trialStartTime: Date?
    
    var body: some View {
        ZStack {
            Background()
                .ignoresSafeArea()
            VStack(spacing: 60) {
                if testEnded {
                    Text("Test Complete")
                    
                    Button {
                        onDismiss()
                    } label: {
                        PrimaryButtonStyleView(title: "Done")
                    }
                    .padding(.horizontal)

                    
                } else {
                    if !questions.isEmpty {
                        let currentQ = questions[currentIndex]
                        
                        VStack(spacing: 30) {
                            Text("Question \(currentIndex + 1)/\(questions.count)")
                                .font(.headline)
                            
                            Text(currentQ.word)
                                .font(.largeTitle)
                                .foregroundStyle(currentQ.color)
                            
                            
                            
                            HStack {
                                ForEach(0..<words.count, id: \.self) { index in
                                    let colorName = words[index]
                                    let colorValue = colors[index]
                                    
                                    Button {
                                        recordAnswer(selectedColor: colorValue)
                                    } label: {
                                        Text(colorName)
                                            .foregroundStyle(Color.gray)
                                            .font(.headline)
                                            .padding(12)
                                            .frame(minWidth: 60)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        .onAppear {
                            trialStartTime = Date()
                        }
                    }
                }
            }
            .onAppear {
                startTest()
            }
        }
    }
    
    func generateQuestions(qCount: Int) -> [Question] {
        var generatedQuestions: [Question] = []
        
        let congruentCount = max(1, qCount / 5)
        
        for _ in 0..<congruentCount {
            let index = Int.random(in: 0..<words.count)
            let word = words[index]
            let color = colors[index]
            
            let question = Question(word: word, color: color, isCongruent: true)
            generatedQuestions.append(question)
        }

        for _ in 0..<(qCount - congruentCount) {
            let wordIndex = Int.random(in: 0..<words.count)
            var colorIndex = Int.random(in: 0..<colors.count)
            
            while wordIndex == colorIndex {
                colorIndex = Int.random(in: 0..<colors.count)
            }
            
            let word = words[wordIndex]
            let color = colors[colorIndex]
            let question = Question(word: word, color: color, isCongruent: false)
            generatedQuestions.append(question)
        }
        
        return generatedQuestions.shuffled()
        
    }
    
    func startTest() {
        questions = generateQuestions(qCount: questionCount)
        currentIndex = 0
        testEnded = false
        reactionTimes = []
        correctness = []
        trialStartTime = Date()
    }
    
    func recordAnswer(selectedColor: Color) {
        guard currentIndex < questions.count else { return }
        let currentQ = questions[currentIndex]
        
        if let start = trialStartTime {
            let reactionTime = Date().timeIntervalSince(start)
            reactionTimes.append(reactionTime)
        } else {
            reactionTimes.append(0.0)
        }
                
   
        let correct = (selectedColor == currentQ.color)
        correctness.append(correct)
        

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
