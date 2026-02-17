////
////  SwiftUIView.swift
////  SSC2026
////
////  Created by Harshitha Rajesh on 1/10/26.
////
//
//import SwiftUI
//
//struct OptionalTestsView: View {
//    let wakeUpTime: Date
//    let circadianLowWindow: String
//    let baseAlertness: AlertnessResult // from InputView
//    
//    @State private var completedTests: [AlertnessTestType: Any] = [:]
//    @State private var selectedTest: AlertnessTestType?
//    @State private var navigateToReduction = false
//    
//    let allTests: [AlertnessTestType] = [.reaction, .matching, .recall, .stroop, .math]
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                Text("Optional Alertness Tests")
//                    .font(.title2)
//                    .bold()
//                
//                List {
//                    ForEach(allTests, id: \.self) { test in
//                        Button {
//                            selectedTest = test
//                        } label: {
//                            HStack {
//                                Text(testDisplayName(test))
//                                Spacer()
//                                if completedTests[test] != nil {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(.green)
//                                }
//                            }
//                        }
//                        .disabled(completedTests[test] != nil)
//                    }
//                }
//                
//                Button("Skip & Continue") {
//                    navigateToReduction = true
//                }
//                .padding()
//            }
//            .navigationTitle("Alertness Tests")
//            .sheet(item: $selectedTest) { testType in
//                testView(for: testType)
//                    .onDisappear {
//                        // Capture results here; simplified example
//                        completedTests[testType] = captureResults(for: testType)
//                    }
//            }
//            .navigationDestination(isPresented: $navigateToReduction) {
//                ReductionView(
//                    alertness: combineResults(base: baseAlertness, tests: completedTests),
//                    circadianLowWindow: circadianLowWindow,
//                    wakeUpTime: wakeUpTime
//                )
//            }
//        }
//    }
//    
//    func testDisplayName(_ test: AlertnessTestType) -> String {
//        switch test {
//        case .reaction: return "Reaction Tap"
//        case .matching: return "Symbol Matching"
//        case .recall: return "Spatial Sequence Recall"
//        case .stroop: return "Stroop Test"
//        case .math: return "Simple Math"
//        }
//    }
//    
//    func captureResults(for test: AlertnessTestType) -> Any {
//        // Placeholder: each test should return a struct with score & accuracy
//        // You would integrate your test state/result variables here
//        switch test {
//        case .reaction: return 70.0   // example reaction time score
//        case .matching: return 80.0
//        case .recall: return 75.0
//        case .stroop: return 65.0
//        case .math: return 78.0
//        }
//    }
//    
//    func combineResults(base: AlertnessResult, tests: [AlertnessTestType: Any]) -> AlertnessResult {
//        // Combine InputView base alertness with test performance
//        // Example: weight baseAlertness 50%, tests 50%
//        let testScores = tests.values.compactMap { $0 as? Double }
//        let averageTestScore = testScores.isEmpty ? 0.0 : testScores.reduce(0,+)/Double(testScores.count)
//        let combinedScore = 0.5 * base.alertnessScore + 0.5 * averageTestScore
//        
//        return AlertnessResult(
//            alertnessScore: combinedScore,
//            confidence: base.confidence,
//            explanation: base.explanation + ["Performance tests adjusted alertness."]
//        )
//    }
//}
//
//#Preview {
//    OptionalTestsView(wakeUpTime: Date(), circadianLowWindow: "4-7AM", baseAlertness: AlertnessResult(alertnessScore: 67.676767, confidence: 0.67, explanation: ["idk"]))
//}
