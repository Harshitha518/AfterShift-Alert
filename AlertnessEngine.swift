//
//
//  File.swift
//  SSC26
//
//  Created by Harshitha Rajesh on 1/2/26.
//

import Foundation


struct AlertnessInputs {
    let circadianScore: Double // 0 - 1
    let sleepPressure: Double // 0 - 1
    let performanceScore: Double // 0 - 100
    let statisticalRisk: Double // 0 - 100
}

struct AlertnessResult {
    let alertnessScore: Double // 0 - 100
    let confidence: Double // 0 - 1
    let explanation: [String]
}

func computeAlertness(inputs: AlertnessInputs) -> AlertnessResult {
    
    // Two process biological model (Process C + Process S)
    let biological = (inputs.circadianScore * 0.6 + (1 - inputs.sleepPressure) * 0.4) * 100
    
    // Combines weighted scores of biological alertness, performance alertness, and statistical alertness
    let fused = (0.45 * biological) + (0.35 * inputs.performanceScore) + (0.20 * (100 - inputs.statisticalRisk))
    
    let confidence = abs(biological - inputs.performanceScore) < 15 ? 0.9 : 0.6
    
    return AlertnessResult(alertnessScore: max(min(fused, 100), 0), confidence: confidence, explanation: [
        "Circadian biology sets baseline alertness.",
        "Performance test adjusts for current attention.",
        "Statistical risk reflects real-world driving danger."
        ]
     )
}

