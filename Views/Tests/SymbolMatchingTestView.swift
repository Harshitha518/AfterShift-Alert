
import SwiftUI

// Symbol matching test
struct SymbolMatchingTestView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onComplete: @MainActor (Double) -> Void
    
    let onDismiss: () -> Void


    
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
    
    @State private var selectedChoice: Int? = nil
    @State private var lastCorrect: Bool? = nil
    
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
                                .foregroundStyle(Color.white)
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
    }

    
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
    
    func buttonColor(for number: Int) -> Color {
        if let selected = selectedChoice, selected == number {
            if let correct = lastCorrect {
                return correct ? .safe : .warning
            }
        }
        return Color.nightAccent
    }
    
    func startTest() {
        correctCount = 0
        timeLeft = testDuration
        testEnded = false
        reactionTimes = []
        selectedChoice = nil
        lastCorrect = nil
        
        var assignedNumbers = Set<Int>()
        for symbol in symbols {
            var num: Int
            repeat {
                num = Int.random(in: 1...9)
            } while assignedNumbers.contains(num)
            assignedNumbers.insert(num)
            symbolNumberMap[symbol] = num
        }
        
        nextSymbol()

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
        var next: String
        repeat {
            next = symbols.randomElement()!
        } while next == currentSymbol
        currentSymbol = next
        symbolShownTime = Date()
    }

    
    func handleAnswer(choice: Int) {
        guard !testEnded else { return }

        let reaction = Date().timeIntervalSince(symbolShownTime)
        reactionTimes.append(reaction)

        if let correctNumber = symbolNumberMap[currentSymbol] {
            lastCorrect = choice == correctNumber
            if lastCorrect! {
                correctCount += 1
            }
        }
        selectedChoice = choice
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard !testEnded else { return }
            nextSymbol()
            selectedChoice = nil
            lastCorrect = nil
        }
    }
    
    func endTest() {
        testEnded = true

        let totalShown = reactionTimes.count
        let accuracy = totalShown > 0 ? Double(correctCount) / Double(totalShown) : 0
        let avgReaction = totalShown > 0
            ? reactionTimes.reduce(0, +) / Double(totalShown)
            : 0

        let maxReaction = 2.0
        let reactionScore = max(0, min(100, 100 * (1 - avgReaction / maxReaction)))

        let score = accuracy * 100 * 0.7 + reactionScore * 0.3

        Task { @MainActor in
            onComplete(score)
        }
    }

}
