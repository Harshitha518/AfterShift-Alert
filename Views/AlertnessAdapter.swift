
import Foundation

struct AlertnessAdapter {

    static func evaluate(
        wakeUpTime: TimeOfDay,
        shiftEndTime: TimeOfDay,
        sleepHistory: [Double],
        hadCloseCall: Bool
    ) -> AlertnessResult {

        let hoursAwake = computeHoursAwake(
            wakeUp: wakeUpTime,
            shiftEnd: shiftEndTime
        )

        let currentHour = shiftEndTime.hour
        
        let lastNightSleep = sleepHistory.first ?? 0
        let requiredSleep = 8.0

        let cumulativeDebt = sleepHistory
            .map { max(0, requiredSleep - $0) }
            .reduce(0, +)

        var score = AlertnessModel.computeAlertness(
            hoursAwake: hoursAwake,
            hoursSleptLast24h: lastNightSleep,
            cumulativeSleepDebt: cumulativeDebt,
            currentHour: currentHour
        )

        var explanations: [String] = []
        var confidence = 0.85

        // Sleep deprivation
        if lastNightSleep < 6 {
            explanations.append(
                "Sleep deprivation detected (\(String(format: "%.1f", lastNightSleep))h < 6h recommended)"
            )
            confidence = min(confidence, 0.75)
        }

        // Extended wakefulness
        if hoursAwake > 16 {
            explanations.append(
                "Extended wakefulness (\(String(format: "%.1f", hoursAwake))h awake)"
            )
            confidence = min(confidence, 0.70)
        }

        // Circadian low detection
        if (3...6).contains(currentHour) {
            explanations.append("Currently in circadian low zone (3–6 AM)")
            score -= 5
            confidence = min(confidence, 0.65)
        }

        // Close-call history
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

        let kss = 9.0 - (score / 100.0) * 7.0

        return AlertnessResult(
            score: score,
            kssEquivalent: kss,
            confidence: confidence,
            explanation: explanations
        )
    }

    
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
        print(min(max(hours, 0), 24)
)
        return min(max(hours, 0), 24)
    }
}


struct TimeOfDay {
    let hour: Int
    let minute: Int

    var minutesSinceMidnight: Int {
        hour * 60 + minute
    }
}

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
