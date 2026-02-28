
import SwiftUI

// Matching sequence test
struct SpatialRecallTestView: View {
    let onComplete: @MainActor (Double) -> Void
    let onDismiss: () -> Void

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
                    Text("Round \(currentRound)/\(totalRounds) — \(showingFlash ? "Watch the sequence" : "Repeat the sequence")")
                        .font(.headline)
                    
                    if !showingFlash {
                        Text("Step \(userInput.count)/\(sequenceLength)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
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
            replicationStartTime = Date()
            return
        }

        showingFlash = true
      
        DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
            currentFlashIndex += 1
            flashNextBlock()
        }
    }

    func colorForBlock(_ index: Int) -> Color {
        if showingFlash && currentFlashIndex < sequence.count && index == sequence[currentFlashIndex] {
            return Color.nightAccent
        } else if userInput.contains(index) {
            return Color.safe
        } else if index == lastTappedBlock {
            return .white.opacity(0.8)
        } else {
            return .gray.opacity(0.3)
        }
    }

    func handleUserTap(_ index: Int) {
        guard let start = replicationStartTime else { return }

        let reaction = Date().timeIntervalSince(start)
        reactionTimes.append(reaction)
        replicationStartTime = Date()

        if userInput.count < sequence.count && index == sequence[userInput.count] {
            correctSteps += 1
        }

        totalTaps += 1
        lastTappedBlock = index
        if userInput.last == index {
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

        let totalSteps = totalTaps
        let accuracy = totalSteps > 0 ? Double(totalCorrectSteps) / Double(totalSteps) : 0

        let avgReaction = reactionTimes.isEmpty ? 0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)

        let maxReaction: Double = 3
        let speedScore = max(0, min(100, 100 * (1 - avgReaction / maxReaction)))

        let alertnessScore = max(0, min(100, accuracy * 100 * 0.7 + speedScore * 0.3))

        Task { @MainActor in
            onComplete(alertnessScore)
        }
    }
}
