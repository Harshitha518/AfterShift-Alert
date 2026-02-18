//
//  TestListView.swift
//  SSC2026
//

import SwiftUI

enum AlertnessTestType: Identifiable {
    case reaction
    case matching
    case recall
    case stroop
    case math

    var id: Self { self }
}

enum TestImportance {
    case primary
    case secondary
}

@MainActor
@ViewBuilder
func testView(
    for test: AlertnessTestType,
    onComplete: @escaping (Double) -> Void,
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

struct AlertnessTest: Identifiable {
    let id = UUID()
    let name: String
    let scientificName: String
    let measures: String
    let domain: CognitiveDomain
    let duration: String
    let symbol: String
    let type: AlertnessTestType
    let importance: TestImportance
}

enum CognitiveDomain {
    case vigilance
    case attention
    case workingMemory
    case executiveFunction
    case mentalCalculation
}

let testWeights: [AlertnessTestType: Double] = [
    .reaction: 0.35,   // reaction time is most critical for driving
    .stroop: 0.30,     // inhibition / cognitive control
    .matching: 0.20,   // attention / processing speed
    .recall: 0.10,     // working memory
    .math: 0.05        // low relevance for driving
]

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
            symbol: "plus.app.fill",
            type: .math,
            importance: .secondary
        )
    ]

    @State private var selectedTest: AlertnessTestType?
    @State private var completedTests: [AlertnessTestType: Double] = [:]
    @State private var goToFaceDetection = false
    
    var body: some View {
        ZStack {
            Background()
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Card {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Optional Performance Tests")
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                                
                                Text("A battery of short cognitive and psychomotor tasks assessing alertness, attention, working memory, and executive function.")
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
                        // Primary Tests
                        if !allTests.filter({ $0.importance == .primary }).isEmpty {
                            Text("Primary Tests")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.top)
                            HStack {
                                ForEach(allTests.filter { $0.importance == .primary }) { test in
                                    TestCard(test: test, completedTests: completedTests, selectedTest: $selectedTest)
                                }
                            }
                        }
                        
                        // Secondary Tests
                        if !allTests.filter({ $0.importance == .secondary }).isEmpty {
                            Text("Secondary Tests")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            ForEach(allTests.filter { $0.importance == .secondary }) { test in
                                TestCard(test: test, completedTests: completedTests, selectedTest: $selectedTest)
                            }
                        }
                        
                        Spacer()
                        
                        // Continue Button
                        Button(completedTests.isEmpty ? "Skip Tests" : "Continue") {
                            goToFaceDetection = true
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(Color.nightAccent))
                        .foregroundStyle(.white)
                    }
                    
                    
                }
                .navigationTitle("Alertness Tests")
                .sheet(item: $selectedTest) { testType in
                    if #available(iOS 16.4, *) {
                        testView(
                            for: testType,
                            onComplete: { score in
                                completedTests[testType] = score
                            },
                            onDismiss: {
                                selectedTest = nil
                            }
                        )
                        .presentationBackground {
                            Background()
                        }
                        .presentationBackgroundInteraction(.disabled)
                    } else {
                        // FIGURE OUT BG FOR HEREEEEE
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
                
                }
                .navigationDestination(isPresented: $goToFaceDetection) {
                    //            FaceDetectionView(
                    //                alertness: combinedAlertness(),
                    //                circadianLowWindow: circadianLowWindow,
                    //                wakeUpTime: wakeUpTime,
                    //                shiftEndTime: shiftEndTime
                    //            )
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
        case 0..<40: return .red
        case 40..<70: return .orange
        default: return .green
        }
    }
    
    func combinedAlertness() -> AlertnessResult {
        // If no tests completed, return base alertness
        if completedTests.isEmpty {
            return baseAlertness
        }
        
        // Calculate weighted penalty
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
        
        // Start with base score
        var finalScore = baseAlertness.score - weightedPenalty
        
        // Critical safety penalties for specific tests
        if let reactionScore = completedTests[.reaction], reactionScore < 40 {
            finalScore -= 15
            testExplanations.append("Critical: Reaction time severely impaired")
        }
        
        if let stroopScore = completedTests[.stroop], stroopScore < 45 {
            finalScore -= 10
            testExplanations.append("Warning: Cognitive control reduced")
        }
        
        // Clamp to valid range
        finalScore = max(0, min(100, finalScore))
        
        // Adjust confidence based on test performance
        var confidence = baseAlertness.confidence
        if weightedPenalty > 20 {
            confidence = min(confidence, 0.50)
        } else if weightedPenalty > 10 {
            confidence = min(confidence, 0.70)
        } else {
            confidence = min(confidence, 0.85)
        }
        
        // Combine explanations
        var allExplanations = baseAlertness.explanation
        allExplanations.append("Performance tests completed: \(completedTests.count)/\(allTests.count)")
        allExplanations.append(contentsOf: testExplanations)
        
        if weightedPenalty > 0 {
            allExplanations.append("Test results indicate \(Int(weightedPenalty)) point reduction in alertness")
        }
        
        // Recalculate KSS based on new score
        let kss = 9.0 - (finalScore / 100.0) * 7.0
        
        return AlertnessResult(
            score: finalScore,
            kssEquivalent: kss,
            confidence: confidence,
            explanation: allExplanations
        )
    }
}


struct TestCard: View {
    var test: AlertnessTest
    var completedTests: [AlertnessTestType: Double]
    @Binding var selectedTest: AlertnessTestType?

    var body: some View {
        HStack {
            Image(systemName: test.symbol)
                .font(.largeTitle)
                .foregroundStyle(Color.nightAccent)
                .padding()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(test.name)
                    .font(.title3.bold())
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("Measures: \(test.measures)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                
                Text("Duration: \(test.duration)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            if let score = completedTests[test.type] {
                VStack(spacing: 2) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.safe)
                    Text("\(score, specifier: "%.0f")%")
                        .font(.caption)
                        .foregroundStyle(Color.secondary.opacity(0.7))
                }
            } else {
                Button {
                    selectedTest = test.type
                } label: {
                    Text("Take Test")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.nightAccent)
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedTest == test.type ? Color.nightAccent : Color.clear, lineWidth: 2)
                )
                .shadow(color: selectedTest == test.type ? Color.nightAccent.opacity(0.4) : .clear, radius: 6, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.3), value: selectedTest)

        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
