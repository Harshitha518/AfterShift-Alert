
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

    @Guide(description: "Provide one clear, practical safety recommendation if alertness remains low. Driving should not be occuring when alertness is low. If alertness is high, say no additional action is needed.")
    var recommendation: String
}

// AI Explanation view
@available(iOS 26.0, *)
struct AIExplanationView: View {

    let alertness: AlertnessResult
    let baseScore: Double
    let finalScore: Double
    let delayMinutes: Double
    let napMinutes: Double
    let caffeineLevel: Int
    let freshAir: Bool
    let departureTime: Date
    let circadianPhase: CircadianPhase

    @State private var responseContent: AlertnessExplanation?

    var body: some View {
        Card {
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let responseContent {
                        Text(responseContent.scoreInterpretation)
                            .foregroundStyle(.white)
                        Text("Strongest improvement: \(responseContent.strongestImprovement)")
                            .foregroundStyle(.white)
                        Text("Remaining risk: \(responseContent.mainRiskFactor)")
                            .foregroundStyle(.white)
                        Text("Recommendation: \(responseContent.recommendation)")
                            .foregroundStyle(.white)
                    } else {
                        ProgressView("Analyzing alertness…")
                    }
                }
                Spacer()
            }
    
        }
        .task {
            if responseContent == nil {
                await generateExplanation()
            }
        }
    }
    func generateExplanation() async {
        let instructions = """
        You are a calm evidence based assistant explaining night shift driving alertness.
        Do not alter numbers.
        Focus on interpreting the score, key improvements, and remaining risks.
        Provide concise structured outputs.
        Any alertness below 40 is extremely low and driving will be dangerous. Anything above 70 is safe.
        Scores are all out of 100.
        """

        let prompt = """
        Explanations: 
        \(alertness.explanation.joined(separator: "\n"))
        
        Base alertness score: \(baseScore) / 100
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

