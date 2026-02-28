//
//  AlertnessModel.swift
//  SSC2026
//
//  Core alertness computation using a constrained Two-Process Model
//  with biologically enforced guards.
//
//  Process S: Homeostatic sleep pressure
//  Process C: Circadian modulation
//
//  Designed to avoid unrealistic alertness under sleep deprivation.
//

import Foundation


struct AlertnessResult {
    let score: Double
    let kssEquivalent: Double
    
    var confidence: Double = 0.95
    var explanation: [String] = []

}

struct AlertnessModel {


    static func computeAlertness(hoursAwake: Double, hoursSleptLast24h: Double, cumulativeSleepDebt: Double, currentHour: Int) -> Double {

        let sleepScore = sleepRecoveryScore(
            hoursSlept: hoursSleptLast24h,
            cumulativeDebt: cumulativeSleepDebt
        )
        let circadianScore = circadianAlertness(hour: currentHour)
        let wakePenalty = wakeDurationPenalty(hoursAwake: hoursAwake)

        //When well-rested, circadian rhythm has less impact
        // When sleep-deprived, circadian rhythm dominates
        let sleepDeprivation = max(0, 8 - hoursSleptLast24h) / 8.0  // 0 to 1
        let sleepWeight = 0.80 - (sleepDeprivation * 0.25)  // 0.55 to 0.80
        let circadianWeight = 1.0 - sleepWeight
            
        var rawScore = sleepWeight * sleepScore + circadianWeight * circadianScore
        rawScore *= 100.0
        rawScore -= wakePenalty
        
        // Biological hard guards
        rawScore = applySleepGuards(score: rawScore, hoursSlept: hoursSleptLast24h)

        return clamp(rawScore, min: 0, max: 100)
    }

    // Process S (non-linear sleep recovery)
    private static func sleepRecoveryScore(hoursSlept: Double, cumulativeDebt: Double) -> Double {
        let h = clamp(hoursSlept, min: 0, max: 9)

        // logistic (sigmoid) function to model recovery curve
      
        let k = 1.2
        let midpoint = 5.5
        

        return 1.0 / (1.0 + exp(-k * (h - midpoint)))
    }

    // Wake Duration Penalty

    private static func wakeDurationPenalty(hoursAwake: Double) -> Double {

        // No penalty under 16h awake
        guard hoursAwake > 16 else { return 0 }

        let excess = hoursAwake - 16
        return min(excess * 3.5, 30) // cap at −30 points
    }

    // Process C (Circadian Rhythm)

    private static func circadianAlertness(hour: Int) -> Double {

        let peakHour = 15.0 // ~3 PM biological peak
        let radians = (2.0 * Double.pi / 24.0) * (Double(hour) - peakHour)

        // Normalize sine wave to 0–1
        return 0.5 + 0.5 * sin(radians)
    }

    // Biological Guards

    private static func applySleepGuards(score: Double, hoursSlept: Double) -> Double {

        // 0 hours of sleep is catastrophic
        if hoursSlept == 0 {
            return min(score, 12)
        }

        // Severe deprivation hard-cap
        if hoursSlept < 4 {
            return min(score, 40)
        }

        // Partial deprivation soft-cap
        if hoursSlept < 6 {
            return min(score, 65)
        }

        return score
    }


    private static func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.max(min, Swift.min(max, value))
    }
    

    
}
