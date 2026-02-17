//
//  SwiftUIView.swift
//  SSC2026
//
//  Created by Harshitha Rajesh on 1/3/26.
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
    let measures: String
    let duration: String
    let type: AlertnessTestType
}


struct TestListView: View {
    let baseAlertness: AlertnessResult
    let circadianLowWindow: String
    let wakeUpTime: Date
    
    var allTests: [AlertnessTest] = [
        AlertnessTest(name: "Reaction Tap", measures: "Simple reaction time", duration: "5-15 secs", type: .reaction),
        AlertnessTest(name: "Symbol Matching", measures: "Attention & processing speed", duration: "15 secs", type: .matching),
        AlertnessTest(name: "Spatial Sequence Recall", measures: "Working memory", duration: "15 - 20 secs", type: .recall),
        AlertnessTest(name: "Stroop Test", measures: "Cognitive control / inhibition", duration: "10 - 20 secs", type: .stroop),
        AlertnessTest(name: "Simple Math", measures: "Focus & mental speed", duration: "10 - 15 secs", type: .math)
    ]
    
    @State private var selectedTest: AlertnessTestType?
    @State private var completedTests: [AlertnessTestType: Double] = [:]
    @State private var goToReduction = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(allTests) { test in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(test.name).font(.headline)
                            Text("Measures: \(test.measures)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Duration: \(test.duration)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if completedTests[test.type] != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Button("Take Test") {
                                selectedTest = test.type
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .disabled(completedTests[test.type] != nil)
                }
                Button("Continue") {
                    goToReduction = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Optional Alertness Tests")
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

            .navigationDestination(isPresented: $goToReduction) {
                ReductionView(
                    alertness: combinedAlertness(),
                    circadianLowWindow: circadianLowWindow,
                    wakeUpTime: wakeUpTime)
            }
            
        }
        
    }

    
    func combinedAlertness() -> AlertnessResult {
        let testScores = completedTests.values
        let avgTestScore = testScores.isEmpty
            ? 0
            : testScores.reduce(0, +) / Double(testScores.count)
            
        let finalScore = testScores.isEmpty
            ? baseAlertness.alertnessScore
            : 0.6 * baseAlertness.alertnessScore + 0.4 * avgTestScore
            
        return AlertnessResult(
            alertnessScore: finalScore,
            confidence: baseAlertness.confidence,
            explanation: baseAlertness.explanation + (
                testScores.isEmpty
                ? ["No performance tests taken."]
                : ["Alertness adjusted using cognitive performance tests."]
            )
        )
    }

}

#Preview {
    TestListView(baseAlertness: AlertnessResult(alertnessScore: 89, confidence: 98, explanation: []), circadianLowWindow: "", wakeUpTime: Date())
}
