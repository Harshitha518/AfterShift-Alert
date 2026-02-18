////
////  SwiftUIView.swift
////  SSC2026
////
////  Created by Harshitha Rajesh on 1/3/26.
////
//
//import SwiftUI
//
//struct SnapshotView: View {
//    let alertnessResult: AlertnessResult
//    let circadianLowWindow: String
//    let wakeUpTime: Date
//
//    var alertnessLevel: String {
//        switch alertnessResult.alertnessScore {
//        case 0..<40:
//            return "Low Alertness"
//        case 40..<70:
//            return "Moderate Alertness"
//        default:
//            return "Higher Alertness"
//        }
//    }
//
//    var alertnessColor: Color {
//        switch alertnessLevel {
//        case "Low Alertness": return .red
//        case "Moderate Alertness": return .yellow
//        default: return .green
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 30) {
//                Spacer()
//
//                Text("\(Int(alertnessResult.alertnessScore))")
//                    .font(.system(size: 200))
//                    .bold()
//                    .foregroundStyle(alertnessColor)
//                    .animation(.easeInOut, value: alertnessResult.alertnessScore)
//
//                Text(alertnessLevel)
//                    .font(.system(size: 60))
//                    .bold()
//                    .foregroundStyle(alertnessColor)
//                
//                
//                
////                VStack(alignment: .leading, spacing: 15) {
////                    HStack {
////                        Text("Circadian Low")
////                        Spacer()
////                        ProgressView(value: 1 - alertnessResult.alertnessScore / 100)         .progressViewStyle(LinearProgressViewStyle(tint: .blue))
////                    }
////                    HStack {
////                        Text("Confidence")
////                        Spacer()
////                        ProgressView(value: alertnessResult.confidence)
////                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
////                    }
////                }
////                .padding(.horizontal)
////
//                Text("You can increase this alertness score before driving.")
//                    .font(.headline)
//
//                NavigationLink("Find my safest drive plan") {
//                    ReductionView(alertness: alertnessResult, circadianLowWindow: "4-7AM", wakeUpTime: wakeUpTime)
//                }
//
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Post-Shift Driving Alertness")
//            .navigationBarTitleDisplayMode(.large)
//        }
//    }
//}
//
//#Preview {
//    SnapshotView(alertnessResult: AlertnessResult(alertnessScore: 62, confidence: 0.78, explanation: []), circadianLowWindow: "", wakeUpTime: Date())
//}
