
import SwiftUI
import FoundationModels

// Instructions for AI explanation
@available(iOS 26.0, *)
@Generable
struct AlertnessExplanation {

    @Guide(description: "One concise sentence explaining what the final alertness score means for driving safety.")
    var scoreInterpretation: String

    @Guide(description: "Identify which intervention contributed the most improvement. Mention only one.")
    var strongestImprovement: String

    @Guide(description: "Identify the strongest remaining risk factor affecting alertness.")
    var mainRiskFactor: String

    @Guide(description: "Provide one clear, practical safety recommendation if risk remains. If risk is low, say no additional action is needed.")
    var recommendation: String
}

// AI Explanation view
@available(iOS 26.0, *)
struct AIExplanationView: View {

    let baseScore: Double
    let finalScore: Double
    let delayMinutes: Double
    let napMinutes: Double
    let caffeineLevel: Int
    let freshAir: Bool
    let departureTime: Date
    let circadianPhase: CircadianPhase
    let cognitiveContribution: Double

    @State private var responseContent: AlertnessExplanation?

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {

                if let responseContent {
                    Text(responseContent.scoreInterpretation)
                    Text("Strongest improvement: \(responseContent.strongestImprovement)")
                    Text("Remaining risk: \(responseContent.mainRiskFactor)")
                    Text("Recommendation: \(responseContent.recommendation)")
                } else {
                    ProgressView("Analyzing alertness…")
                }
            }
            .frame(maxWidth: .infinity)
    
        }
        .task {
            if responseContent == nil {
                await generateExplanation()
            }
        }
    }
    func generateExplanation() async {
        let instructions = """
        You are a calm, evidence-based assistant explaining night-shift driving alertness.
        Do NOT alter numbers.
        Focus on interpreting the score, key improvements, and remaining risks.
        Provide concise structured outputs.
        Any alertness below 40 is extremely low and driving will be dangerous. Anything above 70 is safe.
        """

        let prompt = """
        Base alertness score: \(baseScore) / 100
        Cognitive test contribution: \(cognitiveContribution)
        Interventions:
        - Departure delay: \(delayMinutes) min
        - Nap: \(napMinutes) min
        - Caffeine: \(caffeineLevel)
        - Fresh air: \(freshAir)
        Final adjusted alertness score: \(finalScore) / 100
        Departure time: \(departureTime)
        Circadian phase: \(circadianPhase)
        """

        do {
            let session = LanguageModelSession(instructions: instructions)

            let response = try await session.respond(
                to: prompt,
                generating: AlertnessExplanation.self
            )

            responseContent = response.content
            
        } catch {
            print("AI ERROR:", error)
        }
    }
}

