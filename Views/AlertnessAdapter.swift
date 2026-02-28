
import Foundation

struct AlertnessAdapter {

    // Gets alertness score
    static func evaluate(wakeUpTime: TimeOfDay, shiftEndTime: TimeOfDay, sleepHistory: [Double], hadCloseCall: Bool) -> AlertnessResult {

        // Converts time input into hours awake
        let hoursAwake = computeHoursAwake(
            wakeUp: wakeUpTime,
            shiftEnd: shiftEndTime
        )

        let currentHour = shiftEndTime.hour
        
        // Extracts sleep inputs
        let lastNightSleep = sleepHistory.first ?? 0
        let requiredSleep = 8.0

        // Calculates total debt based on history
        let cumulativeDebt = sleepHistory
            .map { max(0, requiredSleep - $0) }
            .reduce(0, +)

        // Generates basic biology score
        var score = AlertnessModel.computeAlertness(
            hoursAwake: hoursAwake,
            hoursSleptLast24h: lastNightSleep,
            cumulativeSleepDebt: cumulativeDebt,
            currentHour: currentHour
        )

        // Adds logical explanations of which factors have great negative (or positive) effects
        var explanations: [String] = []
        var confidence = 0.85

        // Sleep deprivation
        if lastNightSleep < 6 {
            explanations.append(
                "Sleep deprivation detected (\(String(format: "%.1f", lastNightSleep)) hours < 6 hours recommended)"
            )
            confidence = min(confidence, 0.75)
        }

        // Extended wakefulness
        if hoursAwake > 16 {
            explanations.append(
                "Extended wakefulness (\(String(format: "%.1f", hoursAwake)) hours awake)"
            )
            confidence = min(confidence, 0.70)
        }

        // Circadian low (reinforcement)
        if (3...6).contains(currentHour) {
            explanations.append("Currently in circadian low zone (3–6 am)")
            score -= 5
            confidence = min(confidence, 0.65)
        }

        // Close call history
        if hadCloseCall && score < 70 {
            score *= 0.9
            explanations.append("Previous drowsy driving incidents increase risk")
            confidence = min(confidence, 0.60)
        }

        // Positive case
        if lastNightSleep >= 7 && hoursAwake <= 14 {
            explanations.append("Adequate sleep and limited wake duration")
            confidence = 0.90
        }

        return AlertnessResult(
            score: score,
            confidence: confidence,
            explanation: explanations
        )
    }

    
    // Calculate hours awake
    static func computeHoursAwake(
        wakeUp: TimeOfDay,
        shiftEnd: TimeOfDay
    ) -> Double {

        let wakeMinutes = wakeUp.minutesSinceMidnight
        let endMinutes = shiftEnd.minutesSinceMidnight

        let minutesAwake: Int

        if endMinutes >= wakeMinutes {
            minutesAwake = endMinutes - wakeMinutes
        } else {
            minutesAwake = (24 * 60 - wakeMinutes) + endMinutes
        }

        let hours = Double(minutesAwake) / 60.0

        return min(max(hours, 0), 24)
    }
}

// Stores time simply
struct TimeOfDay {
    let hour: Int
    let minute: Int

    var minutesSinceMidnight: Int {
        hour * 60 + minute
    }
}

// Create a TimeOfDay from data
extension TimeOfDay {
    init(from date: Date) {
        let calendar = Calendar.current
        self.hour = calendar.component(.hour, from: date)
        self.minute = calendar.component(.minute, from: date)
    }
}

extension Date {
    var timeOfDay: TimeOfDay {
        TimeOfDay(from: self)
    }
}
