
import SwiftUI

// Different types of tests
enum AlertnessTestType: Identifiable {
    case reaction
    case matching
    case recall
    case stroop
    case math

    var id: Self { self }
}

// Importance of test to calculating alertness
enum TestImportance {
    case primary
    case secondary
}

// Views for each test
@MainActor
@ViewBuilder
func testView(
    for test: AlertnessTestType,
    onComplete: @Sendable @escaping (Double) -> Void,
    onDismiss: @escaping () -> Void
) -> some View {
    switch test {
    case .reaction:
        ReactionTapTestView(onComplete: onComplete, onDismiss: onDismiss)
    case .matching:
        SymbolMatchingTestView(onComplete: onComplete, onDismiss: onDismiss)
    case .recall:
        SpatialRecallTestView(onComplete: onComplete, onDismiss: onDismiss)
    case .stroop:
        StroopTestView(onComplete: onComplete, onDismiss: onDismiss)
    case .math:
        SimpleMathTestView(onComplete: onComplete, onDismiss: onDismiss)
    }
}

// Components of alertness tests
struct AlertnessTest: Identifiable {
    let id = UUID()
    let name: String
    let scientificName: String
    let measures: String
    let domain: CognitiveDomain
    let duration: String
    let instructions: String
    let symbol: String
    let type: AlertnessTestType
    let importance: TestImportance
}

// Type of domains
enum CognitiveDomain {
    case vigilance
    case attention
    case workingMemory
    case executiveFunction
    case mentalCalculation
}

// Value/weightage of each test
let testWeights: [AlertnessTestType: Double] = [
    .reaction: 0.35,
    .stroop: 0.30,
    .matching: 0.20,
    .recall: 0.10,
    .math: 0.05
]

// View showing option of all tests to take
struct TestListView: View {
    let baseAlertness: AlertnessResult
    let circadianLowWindow: String
    let wakeUpTime: Date
    let shiftEndTime: Date

    let allTests: [AlertnessTest] = [
        AlertnessTest(
            name: "Reaction Tap",
            scientificName: "Simple Reaction Time (SRT) Task",
            measures: "Simple reaction time",
            domain: .vigilance,
            duration: "5–15 sec",
            instructions: "Wait for the screen to turn green, then tap as quickly as possible. There will be 5 rounds. Measures how alert and responsive you are right now.",
            symbol: "bolt.fill",
            type: .reaction,
            importance: .primary
        ),
        AlertnessTest(
            name: "Symbol Matching",
            scientificName: "Choice Reaction / Symbol Matching Task",
            measures: "Attention & processing speed",
            domain: .attention,
            duration: "15 sec",
            instructions: "Select the number that matches the symbol that appears on the screen based on the key as fast as you can before the 15 second timer runs out. Measures focus, attention, and processing speed.",
            symbol: "xmark.triangle.circle.square.fill",
            type: .matching,
            importance: .secondary
        ),
        AlertnessTest(
            name: "Spatial Sequence Recall",
            scientificName: "Corsi Block / Spatial Span Task",
            measures: "Working memory",
            domain: .workingMemory,
            duration: "15–20 sec",
            instructions: "Memorize the sequence of the highlighted 5 squares and reproduce it in order. There will be 5 rounds. Measures your short-term spatial memory.",
            symbol: "square.grid.3x3.middleleft.filled",
            type: .recall,
            importance: .secondary
        ),
        AlertnessTest(
            name: "Stroop Test",
            scientificName: "Stroop Color-Word Interference Task",
            measures: "Cognitive control / inhibition",
            domain: .executiveFunction,
            duration: "10–20 sec",
            instructions: "Select the correct color of the word, not what the word says, as fast as possible. There are 25 rounds. Measures your cognitive control and ability to resist distractions.",
            symbol: "brain.fill",
            type: .stroop,
            importance: .primary
        ),
        AlertnessTest(
            name: "Simple Math",
            scientificName: "Mental Arithmetic Task",
            measures: "Focus & mental speed",
            domain: .mentalCalculation,
            duration: "10–15 sec",
            instructions: "Solve quick addition problems as accurately and fast as possible. There are 25 rounds. Measures focus, calculation speed, and mental alertness.",
            symbol: "plus.app.fill",
            type: .math,
            importance: .secondary
        )
    ]

    @State private var showingPreTest: AlertnessTest? = nil
    @State private var selectedTest: AlertnessTestType? = nil
    @State private var completedTests: [AlertnessTestType: Double] = [:]
    @State private var goToFaceDetection = false

    var body: some View {
        ZStack {
            Background()
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    // Instructions + tracker and tests
                    Card {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Optional Performance Tests")
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                                
                                Text("A battery of short cognitive and psychomotor tasks assessing alertness, attention, working memory, and executive function. All of these tests are optional, but will improve accuracy of your Alertness score, as they are measuring alertness in real time.")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(.bottom)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "list.number")
                                    Text("Step \(completedTests.count) of \(allTests.count)")
                                        .font(.headline)
                                }
                                .foregroundStyle(.white.opacity(0.85))
                                
                                
                                ProgressView(
                                    value: Double(completedTests.count),
                                    total: Double(allTests.count)
                                )
                                .progressViewStyle(LinearProgressViewStyle(tint: .nightAccent))
                                .frame(height: 6)
                                .padding(.vertical, 4)
                                
                                
                            }
                            Spacer()
                        }
                    }
                    .padding(.bottom, 10)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        if !allTests.filter({ $0.importance == .primary }).isEmpty {
                            Text("Primary Tests")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.top)
                            HStack {
                                ForEach(allTests.filter { $0.importance == .primary }) { test in
                                    TestCard(test: test, completedTests: completedTests, showingPreTest: $showingPreTest)
                                }
                            }
                        }


                        if !allTests.filter({ $0.importance == .secondary }).isEmpty {
                            Text("Secondary Tests")
                                .font(.headline)
                                .foregroundStyle(.white)

                            ForEach(allTests.filter { $0.importance == .secondary }) { test in
                                TestCard(test: test, completedTests: completedTests, showingPreTest: $showingPreTest)
                            }
                        }

                        Spacer()
                        
                        Button(action: {
                            goToFaceDetection = true
                        }) {
                            PrimaryButtonStyleView(title: completedTests.isEmpty ? "Skip Tests" : "Continue")
                        }

                    }
                }
                .navigationTitle("Alertness Tests")
                .sheet(item: $showingPreTest) { test in
                    PreTestInfoView(test: test) {
                        selectedTest = test.type
                        showingPreTest = nil
                    }
                }
                .sheet(item: $selectedTest) { testType in
                    testView(
                        for: testType,
                        onComplete: { score in
                            completedTests[testType] = score
                        },
                        onDismiss: {
                            selectedTest = nil
                        }
                    )
                }
                .navigationDestination(isPresented: $goToFaceDetection) {
                    ReductionView(
                        alertness: combinedAlertness(),
                        circadianLowWindow: circadianLowWindow,
                        wakeUpTime: wakeUpTime,
                        shiftEndTime: shiftEndTime
                    )
                }
                .padding(40)
            }
        }
    }
    
    private func scoreColor(for score: Double) -> Color {
        switch score {
        case 0..<40: return .warning
        case 40..<70: return .orange
        default: return .safe
        }
    }
    
    func combinedAlertness() -> AlertnessResult {
        if completedTests.isEmpty {
            return baseAlertness
        }

        var weightedPenalty = 0.0
        var testExplanations: [String] = []
        
        for (testType, testScore) in completedTests {
            let weight = testWeights[testType] ?? 0
            let penalty = (100 - testScore) * weight
            weightedPenalty += penalty
            
            if testScore < 60 {
                let testName = allTests.first(where: { $0.type == testType })?.name ?? "Test"
                testExplanations.append("\(testName): Low score (\(Int(testScore))%) indicates impairment")
            }
        }
        

        var finalScore = baseAlertness.score - weightedPenalty

        
        if let reactionScore = completedTests[.reaction], reactionScore < 40 {
            finalScore -= 15
            testExplanations.append("Critical: Reaction time severely impaired")
        }
        
        if let stroopScore = completedTests[.stroop], stroopScore < 45 {
            finalScore -= 10
            testExplanations.append("Warning: Cognitive control reduced")
        }
        

        finalScore = max(0, min(100, finalScore))
        
        var confidence = baseAlertness.confidence
        if weightedPenalty > 20 {
            confidence = min(confidence, 0.50)
        } else if weightedPenalty > 10 {
            confidence = min(confidence, 0.70)
        } else {
            confidence = min(confidence, 0.85)
        }
        

        var allExplanations = baseAlertness.explanation
        allExplanations.append("Performance tests completed: \(completedTests.count)/\(allTests.count)")
        allExplanations.append(contentsOf: testExplanations)
        
        if weightedPenalty > 0 {
            allExplanations.append("Test results indicate \(Int(weightedPenalty)) point reduction in alertness")
        }
        
        
        let kss = 9.0 - (finalScore / 100.0) * 7.0
        
        return AlertnessResult(
            score: finalScore,
            kssEquivalent: kss,
            confidence: confidence,
            explanation: allExplanations
        )
    }
}
