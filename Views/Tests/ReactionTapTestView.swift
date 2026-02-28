
import SwiftUI

// Reaction test
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
            Background()
                .ignoresSafeArea()
            VStack(spacing: 32) {
                if testEnded {
                    VStack(spacing: 60) {
                        Text("Test Complete")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        
                        Button {
                            onDismiss()
                        } label: {
                            PrimaryButtonStyleView(title: "Done")
                        }
                        .padding(.horizontal)


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
                        .fill(isWaiting ? Color.warning : Color.safe)
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
            
            let avgSec = averageReactionTime()

            let reactionScore: Double
            if avgSec < 0.25 {
                reactionScore = 100
            } else if avgSec < 0.4 {
                reactionScore = 100 - ((avgSec - 0.25) / 0.15) * 30
            } else if avgSec < 0.6 {
                reactionScore = 70 - ((avgSec - 0.4) / 0.2) * 30
            } else {
                reactionScore = max(0, 40 - ((avgSec - 0.6) / 0.4) * 40)
            }

            Task { @MainActor in
                onComplete(reactionScore)
            }
            
            return
        }
        
        isWaiting = true
        message = "Wait for green..."
        startTime = nil
        
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

        let reactionTime = Date().timeIntervalSince(startTime)

        reactionTimes.append(reactionTime)
        message = "Good! \(String(format: "%.0f", reactionTime * 1000))ms"

        currentStimulus += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startNextStimulus()
        }
    }
    
    func averageReactionTime() -> Double {
        guard !reactionTimes.isEmpty else { return 0.0 }
        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        return avg
    }
}
