// Calculates overall alertness (0 - 100) based on two main factors:
//      - Process S (sleep/homeostatic pressure)
//      - Process C (circadian rhythm)

import Foundation

struct AlertnessResult {
    let score: Double
    
    var confidence: Double = 0.95
    var explanation: [String] = []

}

struct AlertnessModel {

    // Calculates overall alertness score
    static func computeAlertness(hoursAwake: Double, hoursSleptLast24h: Double, cumulativeSleepDebt: Double, currentHour: Int) -> Double {

        // Process S
        let sleepScore = sleepRecoveryScore(
            hoursSlept: hoursSleptLast24h,
            cumulativeDebt: cumulativeSleepDebt
        )
        // Process C
        let circadianScore = circadianAlertness(hour: currentHour)
        
        let wakePenalty = wakeDurationPenalty(hoursAwake: hoursAwake)
        
        // When well rested, circadian rhythm has less impact, but when sleep deprived, circadian rhythm dominates
        // Calculate sleep debt out of 8 hours on a 0 - 1 scale
        let sleepDeprivation = max(0, 8 - hoursSleptLast24h) / 8.0
        // How much influence Process S has on alertness score on scale from 0.55 - 0.80
        let sleepWeight = 0.80 - (sleepDeprivation * 0.25)
        // Sets weight of Process C
        let circadianWeight = 1.0 - sleepWeight
            
        // Biological score - combines Process S + C normalized alertness scores into one from 0 - 1
        var rawScore = sleepWeight * sleepScore + circadianWeight * circadianScore
        
        // Converts to 100 scale
        rawScore *= 100.0
        // Subtracts penalty
        rawScore -= wakePenalty
        
        // Applies biological limits on score
        rawScore = applySleepGuards(score: rawScore, hoursSlept: hoursSleptLast24h)

        return clamp(rawScore, min: 0, max: 100)
    }

    // Process S (non-linear sleep recovery)
    private static func sleepRecoveryScore(hoursSlept: Double, cumulativeDebt: Double) -> Double {
        
        // Hours of sleep last night restricted between 0 - 9 (recovery benefit plateaus around 9 hours)
        let h = clamp(hoursSlept, min: 0, max: 9)

        // Biological anchors
        let requiredSleep = 8.0
        let chronicRestrictionThreshold = 6.0
        
        // Recovery transitions around chronic restriction boundary
        let steepness = 1.0
        // Logistic (sigmoid) function to model recovery curve
        let baseRecovery = 1.0 / (1.0 + exp(-steepness * (h - chronicRestrictionThreshold)))

    
        // Sleep debt over multiple days reduces recovery efficiency
        let normalizedDebt = cumulativeDebt / requiredSleep
        // Suppression capped at 50%
        let debtImpact = min(normalizedDebt, 0.5)
        
        return baseRecovery * (1.0 - debtImpact)
    }

    // Wake duration penalty (reduction in alertness from being awake over time)
    private static func wakeDurationPenalty(hoursAwake: Double) -> Double {

        // Being awake impairs alertness significantly after ~16 hours
        guard hoursAwake > 16 else { return 0 }

        // Penalize for hours awake past threshold
        let excess = hoursAwake - 16
        // Cap max at 25, so it doesn't dominate score
        return min(excess * 3.5, 25)
    }

    // Process C (sinusoidal circadian rhythm)
    private static func circadianAlertness(hour: Int) -> Double {
        
        let x = Double(hour)
        let period = 24.0
        
        // Phase shift to make trough at 4 am
        let phaseShift = -5.0 * Double.pi / 6.0

        // Use sine function to represent circadian cycle
        let radians = (2.0 * Double.pi / period) * x + phaseShift

        // Normalize sine wave to 0 - 1
        return 0.5 + 0.5 * sin(radians)
    }

    // Biological guards (prevents model from producing unrealistic high scores for extreme cases)
    private static func applySleepGuards(score: Double, hoursSlept: Double) -> Double {

        // 0 hours of sleep = extreme impairment
        if hoursSlept == 0 {
            return min(score, 12)
        }

        // < 4 hours of sleep = severely sleep deprived, but not completely without sleep
        if hoursSlept < 4 {
            return min(score, 40)
        }

        // < 6 = parial sleep deprivation, alertness still impaired, but not as badly
        if hoursSlept < 6 {
            return min(score, 65)
        }

        return score
    }


    // Ensures final score stays between 0 - 100
    private static func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.max(min, Swift.min(max, value))
    }
    

    
}
