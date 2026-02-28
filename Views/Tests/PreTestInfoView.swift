import SwiftUI

// Instructions + info before taking test
struct PreTestInfoView: View {
    let test: AlertnessTest
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: test.symbol)
                .font(.system(size: 60))
                .foregroundStyle(Color.nightAccent)

            Text(test.name)
                .font(.title.bold())
                .foregroundStyle(.white)

            Text("Scientific Name: \(test.scientificName)")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))

            Text("Measures: \(test.measures)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Text("Duration: \(test.duration)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            
            Divider()
                .background(Color.white.opacity(0.5))
                .padding(.vertical, 8)

            Text(test.instructions)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)


            Spacer()

            Button(action: onStart) {
                PrimaryButtonStyleView(title: "Start Test")
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Background())
    }
}
